`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  
// 
// Create Date: 2024/08/27 09:39:16
// Design Name: Top Controller
// Module Name: Controller
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


module Controller(
    input wire          clk,
    input wire          rst,
    input wire          dispatcher_done,
    input wire          pe_done,
    input wire          zcip_done,
    input wire          empty,
    input wire [223:0]  index_vector_buffer,
    input wire          index_en, //  index_vector buffer
    output reg [1:0]   a_mode,
    output reg [1:0]   w_mode,
    output reg [5:0]   w_read_address,
    output reg [5:0]   a_read_address,
    output reg         en,
    output reg [1:0]   acc_en,
    output reg [223:0] index_vector, // 32*7bit
    output reg         weight_sign_en,
    output reg [5:0]   w_write_address,
    output reg [5:0]   a_write_address,
    output reg [15:0]  sram_w_read_address,
    output reg [15:0]  sram_a_read_address,
    output reg [15:0]  sram_write_address,
    output reg         sram_en,
    output reg         done
    );

    //  
    parameter IDLE          = 3'd0;
    parameter FETCH_DATA    = 3'd1;
    parameter DISPATCH      = 3'd2;
    parameter COMPUTE       = 3'd3;
    parameter CHECK_DONE    = 3'd4;
    parameter DONE          = 3'd5;
    parameter FETCH_SRAM    = 3'd6;
    parameter UPDATE_BUFFER = 3'd7;

    reg [2:0]   current_state;
    reg [2:0]   next_state;

    reg [223:0] index_vector_reg1;
    reg [223:0] index_vector_reg2;
    reg reg_sel;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            index_vector_reg1 <= 0;
            index_vector_reg2 <= 0;
        end
        else if (index_en & reg_sel) begin
            index_vector_reg2 <= index_vector_buffer;
        end
        else if (index_en & ~reg_sel) begin
            index_vector_reg1 <= index_vector_buffer;
        end
    end

    //  
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (!rst) begin
                    next_state = empty? FETCH_SRAM : FETCH_DATA;
                end
            end

            FETCH_SRAM: begin
                if (~empty) begin
                    next_state = UPDATE_BUFFER;
                end
            end

            UPDATE_BUFFER: begin
                next_state = FETCH_DATA;
            end

            FETCH_DATA: begin
                if (dispatcher_done) begin
                    next_state = DISPATCH;
                end
            end

            DISPATCH: begin
                if (zcip_done) begin  //  
                    next_state = COMPUTE;
                end
            end

            COMPUTE: begin
                if (pe_done) begin  // All PE rows done
                    next_state = CHECK_DONE;
                end
            end

            CHECK_DONE: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    //  
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            reg_sel <= 0;
        end else if(pe_done) begin
            reg_sel <= ~reg_sel;
        end
    end

    //  
    always @(*) begin
        a_mode              = 2'b00;
        w_mode              = 2'b00;
        w_read_address      = 6'b0;
        a_read_address      = 6'b0;
        w_write_address     = 6'b0;
        a_write_address     = 6'b0;
        sram_w_read_address = 0;
        sram_a_read_address = 0;
        en                  = 1'b0;
        acc_en              = 2'b0;
        index_vector        = 224'b0;
        done                = 1'b0;
        weight_sign_en      = 0;
        sram_a_read_address = 0;
        sram_en             = 0;
        sram_write_address  = 0;

        case (current_state)
            FETCH_SRAM: begin
                sram_w_read_address = sram_w_read_address + 1;
                sram_a_read_address = sram_a_read_address + 1;
                sram_en = 1;
            end

            UPDATE_BUFFER: begin
                a_write_address = sram_a_read_address;
                w_write_address = sram_w_read_address;
            end

            FETCH_DATA: begin
                //   Dispatcher 
                a_read_address = a_read_address + 1;
                w_read_address = w_read_address + 1;
                en = 1'b1;  //  
            end

            DISPATCH: begin
                weight_sign_en = 2'b1;
            end

            COMPUTE: begin
                // PE 
                acc_en = 2'b11;  //  
                if (reg_sel) begin
                    index_vector = index_vector_reg1;
                end else begin
                    index_vector = index_vector_reg2;
                end
            end

            // CHECK_DONE: begin
            //     //
            //     if (pe_done) begin
            //         done <= 1'b1;
            //     end
            // end

            DONE: begin
                done = 1'b1;
                sram_write_address = sram_a_read_address;
            end
        endcase
    end
endmodule
