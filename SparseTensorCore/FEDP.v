`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 11:13:01
// Design Name: 
// Module Name: FEDP
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


module FEDP(
    input  wire clk,                       //  
    input  wire rst,                       //  
    input  wire signed [7:0] weight0,      //  
    input  wire signed [7:0] weight1,
    input  wire signed [7:0] weight2,
    input  wire signed [7:0] weight3,
    input  wire signed [7:0] activation0,  // 
    input  wire signed [7:0] activation1,
    input  wire signed [7:0] activation2,
    input  wire signed [7:0] activation3,
    input  wire signed [15:0] partial_sum, // 
    output reg signed [15:0] result        // 
);

    //  
    reg signed [15:0] product0_stage1;
    reg signed [15:0] product1_stage1;
    reg signed [15:0] product2_stage1;
    reg signed [15:0] product3_stage1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product0_stage1 <= 16'b0;
            product1_stage1 <= 16'b0;
            product2_stage1 <= 16'b0;
            product3_stage1 <= 16'b0;
        end else begin
            product0_stage1 <= weight0 * activation0;
            product1_stage1 <= weight1 * activation1;
            product2_stage1 <= weight2 * activation2;
            product3_stage1 <= weight3 * activation3;
        end
    end

    //  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 16'b0;
        end else begin
            result <= partial_sum + product0_stage1 + product1_stage1 + product2_stage1 + product3_stage1;
        end
    end

endmodule
