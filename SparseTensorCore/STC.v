`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/04 23:00:30
// Design Name: 
// Module Name: STC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module STC(
    input wire              clk,
    input wire              rst,
    input wire [511:0]      a_data_in,
    input wire [255:0]      b_data_in,
    input wire [511:0]      c_data_in,
    input wire [127:0]      weight_idx_in,
    output wire [511:0]     result_out
    );

    // STC 与TC buffer大小相同，只是增加替换的频率，以int8的tensor core为例
    // 每个thread group中 A两行，B两列，组成四个结果
    // B buffer数据由两个thread group共享，因此
    // A buffer 需要2*4*4个数，共32B，每拍输出2*2*4*8b = 128b
    // B buffer 需要4*8个数，共32B，每拍输出2*4*8b = 64b
    // C buffer 需要8*8个数，用int16存储，共128B，每拍输出8个数 8*16b = 128b

    localparam A_DATA_WIDTH = 128;
    localparam A_BUFFER_SIZE = 32;
    localparam A_BUFFER_DEPTH = A_BUFFER_SIZE * 8 / A_DATA_WIDTH;
    localparam A_ADDR_WIDTH = $clog2(A_BUFFER_DEPTH);
    localparam B_DATA_WIDTH = 128;
    localparam B_BUFFER_SIZE = 32;
    localparam B_BUFFER_DEPTH = B_BUFFER_SIZE * 8 / B_DATA_WIDTH;
    localparam B_ADDR_WIDTH = $clog2(B_BUFFER_DEPTH);
    localparam C_DATA_WIDTH = 128;    
    localparam C_BUFFER_SIZE = 128;
    localparam C_BUFFER_DEPTH = C_BUFFER_SIZE * 8 / C_DATA_WIDTH;
    localparam C_ADDR_WIDTH = $clog2(C_BUFFER_DEPTH);

    reg [3:0]  start;
    reg [3:0]  fetch_done;
    reg [3:0]  start_t;         // for combinational logic
    reg [3:0]  fetch_done_t;    // for combinational logic

    wire [A_DATA_WIDTH*4-1:0]   a_data_in0;
    wire [B_DATA_WIDTH*4-1:0]   b_data_in0;
    wire [C_DATA_WIDTH*4-1:0]   c_data_in0;
    wire [C_DATA_WIDTH*4-1:0]   result_out0;

    wire [A_DATA_WIDTH*4-1:0]   a_data_in1;
    wire [B_DATA_WIDTH*4-1:0]   b_data_in1;
    wire [C_DATA_WIDTH*4-1:0]   c_data_in1;
    wire [C_DATA_WIDTH*4-1:0]   result_out1;

    wire [A_DATA_WIDTH*4-1:0]   a_data_in2;
    wire [B_DATA_WIDTH*4-1:0]   b_data_in2;
    wire [C_DATA_WIDTH*4-1:0]   c_data_in2;
    wire [C_DATA_WIDTH*4-1:0]   result_out2;

    wire [A_DATA_WIDTH*4-1:0]   a_data_in3;
    wire [B_DATA_WIDTH*4-1:0]   b_data_in3;
    wire [C_DATA_WIDTH*4-1:0]   c_data_in3;
    wire [C_DATA_WIDTH*4-1:0]   result_out3;

    wire [127:0] weight_idx_in0;
    wire [127:0] weight_idx_in1;
    wire [127:0] weight_idx_in2;
    wire [127:0] weight_idx_in3;

    wire [3:0]  state0;
    wire [3:0]  state1;
    wire [3:0]  state2;
    wire [3:0]  state3;

    // Control logic state pipelined
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            start <= 0;
            fetch_done <= 0;
        end else begin
            start <= start_t;
            fetch_done <= fetch_done_t;
        end
    end

    always@(*) begin
        case(start)
            4'b0000: begin
                start_t = 4'b0001;
                fetch_done_t = 4'b0000;
            end
            4'b0001: begin
                start_t = 4'b0010;
                fetch_done_t = 4'b0001;
            end
            4'b0100: begin
                start_t = 4'b1000;
                fetch_done_t = 4'b0100;
            end
            4'b1000: begin
                start_t = 4'b0001;
                fetch_done_t = 4'b1000;
            end
            default: begin
                start_t = 0;
                fetch_done_t = 0;
            end
        endcase
    end

    assign a_data_in0 = state0[1]? a_data_in : 0;
    assign b_data_in0 = state0[1]? b_data_in : 0;
    assign c_data_in0 = state0[1]? c_data_in : 0;
    
    assign a_data_in1 = state1[1]? a_data_in : 0;
    assign b_data_in1 = state1[1]? b_data_in : 0;
    assign c_data_in1 = state1[1]? c_data_in : 0;

    assign a_data_in2 = state2[1]? a_data_in : 0;
    assign b_data_in2 = state2[1]? b_data_in : 0;
    assign c_data_in2 = state2[1]? c_data_in : 0;

    assign a_data_in3 = state3[1]? a_data_in : 0;
    assign b_data_in3 = state3[1]? b_data_in : 0;
    assign c_data_in3 = state3[1]? c_data_in : 0;
    
    assign weight_idx_in0 = state0[1]? weight_idx_in : 0;
    assign weight_idx_in1 = state1[1]? weight_idx_in : 0;
    assign weight_idx_in2 = state2[1]? weight_idx_in : 0;
    assign weight_idx_in3 = state3[1]? weight_idx_in : 0;

    assign result_out = state0[3]? result_out0: 
            (state1[3]? result_out1:
            (state2[3]? result_out2:
            (state3[3]? result_out3:0)));


    spTensorCore #(
        .A_DATA_WIDTH    (A_DATA_WIDTH ),
        .A_BUFFER_SIZE   (A_BUFFER_SIZE),
        .A_BUFFER_DEPTH  (A_BUFFER_DEPTH),
        .A_ADDR_WIDTH    (A_ADDR_WIDTH),
        .B_DATA_WIDTH    (B_DATA_WIDTH ),
        .B_BUFFER_SIZE   (B_BUFFER_SIZE),
        .B_BUFFER_DEPTH  (B_BUFFER_DEPTH),
        .B_ADDR_WIDTH    (B_ADDR_WIDTH),
        .C_DATA_WIDTH    (C_DATA_WIDTH ),
        .C_BUFFER_SIZE   (C_BUFFER_SIZE),
        .C_BUFFER_DEPTH  (C_BUFFER_DEPTH),
        .C_ADDR_WIDTH    (C_ADDR_WIDTH)
    )spTensorCore0(
        .clk                (clk),
        .rst                (rst),
        .start              (start[0]),
        .fetch_done         (fetch_done[0]),
        .a_data_in          (a_data_in0),
        .b_data_in          (b_data_in0),
        .c_data_in          (c_data_in0),
        .weight_idx_in      (weight_idx_in0),
        .idle_out           (state0[0]),
        .fetch_out          (state0[1]),
        .compute_out        (state0[2]),
        .write_back_out     (state0[3]),
        .result_out         (result_out0)
    );

    spTensorCore #(
        .A_DATA_WIDTH    (A_DATA_WIDTH ),
        .A_BUFFER_SIZE   (A_BUFFER_SIZE),
        .A_BUFFER_DEPTH  (A_BUFFER_DEPTH),
        .A_ADDR_WIDTH    (A_ADDR_WIDTH),
        .B_DATA_WIDTH    (B_DATA_WIDTH ),
        .B_BUFFER_SIZE   (B_BUFFER_SIZE),
        .B_BUFFER_DEPTH  (B_BUFFER_DEPTH),
        .B_ADDR_WIDTH    (B_ADDR_WIDTH),
        .C_DATA_WIDTH    (C_DATA_WIDTH ),
        .C_BUFFER_SIZE   (C_BUFFER_SIZE),
        .C_BUFFER_DEPTH  (C_BUFFER_DEPTH),
        .C_ADDR_WIDTH    (C_ADDR_WIDTH)
    )spTensorCore1(
        .clk                (clk),
        .rst                (rst),
        .start              (start[1]),
        .fetch_done         (fetch_done[1]),
        .a_data_in          (a_data_in1),
        .b_data_in          (b_data_in1),
        .weight_idx_in      (weight_idx_in1),
        .c_data_in          (c_data_in1),
        .idle_out           (state1[0]),
        .fetch_out          (state1[1]),
        .compute_out        (state1[2]),
        .write_back_out     (state1[3]),
        .result_out         (result_out1)
    );

    spTensorCore #(
        .A_DATA_WIDTH    (A_DATA_WIDTH ),
        .A_BUFFER_SIZE   (A_BUFFER_SIZE),
        .A_BUFFER_DEPTH  (A_BUFFER_DEPTH),
        .A_ADDR_WIDTH    (A_ADDR_WIDTH),
        .B_DATA_WIDTH    (B_DATA_WIDTH ),
        .B_BUFFER_SIZE   (B_BUFFER_SIZE),
        .B_BUFFER_DEPTH  (B_BUFFER_DEPTH),
        .B_ADDR_WIDTH    (B_ADDR_WIDTH),
        .C_DATA_WIDTH    (C_DATA_WIDTH ),
        .C_BUFFER_SIZE   (C_BUFFER_SIZE),
        .C_BUFFER_DEPTH  (C_BUFFER_DEPTH),
        .C_ADDR_WIDTH    (C_ADDR_WIDTH)
    )spTensorCore2(
        .clk                (clk),
        .rst                (rst),
        .start              (start[2]),
        .fetch_done         (fetch_done[2]),
        .a_data_in          (a_data_in2),
        .b_data_in          (b_data_in2),
        .weight_idx_in      (weight_idx_in2),
        .c_data_in          (c_data_in2),
        .idle_out           (state2[0]),
        .fetch_out          (state2[1]),
        .compute_out        (state2[2]),
        .write_back_out     (state2[3]),
        .result_out         (result_out2)
    );

    spTensorCore #(
        .A_DATA_WIDTH    (A_DATA_WIDTH ),
        .A_BUFFER_SIZE   (A_BUFFER_SIZE),
        .A_BUFFER_DEPTH  (A_BUFFER_DEPTH),
        .A_ADDR_WIDTH    (A_ADDR_WIDTH),
        .B_DATA_WIDTH    (B_DATA_WIDTH ),
        .B_BUFFER_SIZE   (B_BUFFER_SIZE),
        .B_BUFFER_DEPTH  (B_BUFFER_DEPTH),
        .B_ADDR_WIDTH    (B_ADDR_WIDTH),
        .C_DATA_WIDTH    (C_DATA_WIDTH ),
        .C_BUFFER_SIZE   (C_BUFFER_SIZE),
        .C_BUFFER_DEPTH  (C_BUFFER_DEPTH),
        .C_ADDR_WIDTH    (C_ADDR_WIDTH)
    )spTensorCore3(
        .clk                (clk),
        .rst                (rst),
        .start              (start[3]),
        .fetch_done         (fetch_done[3]),
        .a_data_in          (a_data_in3),
        .b_data_in          (b_data_in3),
        .weight_idx_in      (weight_idx_in3),
        .c_data_in          (c_data_in3),
        .idle_out           (state3[0]),
        .fetch_out          (state3[1]),
        .compute_out        (state3[2]),
        .write_back_out     (state3[3]),
        .result_out         (result_out3)
    );

endmodule
