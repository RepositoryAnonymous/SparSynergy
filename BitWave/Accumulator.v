`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 08:50:52
// Design Name: 
// Module Name: accumulator
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


module Accumulator(
    input wire clk,
    input wire rst,
    input wire [1:0]  en,         // 
    input wire [15:0] in0,        // 
    input wire [15:0] in1,        // 
    input wire [15:0] in2,        // 
    input wire [15:0] in3,        // 
    input wire        ready,
    output reg        done,
    // output reg [1:0]  status,     // 
    output reg [63:0] final_out   // 
);

    reg [15:0] sum1;
    reg [15:0] sum2;
    reg [15:0] sum3;

    reg [63:0] tmp_out;

    // 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum1 <= 16'd0;
            sum2 <= 16'd0;
        end else if (en[0]&ready) begin
            sum1 <= in0 + in1;
            sum2 <= in2 + in3;
        end
    end

    // 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum3 <= 16'd0;
        end else if (en[1]&ready) begin
            sum3 <= sum1 + sum2;
        end
    end

    always@(*) begin
        case(en)
            2'b00: tmp_out = {in0, in1, in2, in3};
            2'b01: tmp_out = {32'b0, sum1, sum2};
            2'b11: tmp_out = {48'b0, sum3};
            default: tmp_out = 64'b0;
        endcase
    end
    
    // 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            final_out <= 16'd0;
            done <= 0;
        end else begin
            final_out <= tmp_out;
            done <= 1;
        end
    end

endmodule

