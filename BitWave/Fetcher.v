`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 10:55:12
// Design Name: 
// Module Name: Fetcher
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


// module Fetcher(
//     input wire          clk,
//     input wire          rst,
//     input wire [5:0]    w_read_address,    // 选择要读取的片上缓冲区
//     input wire [5:0]    a_read_address,    // 要读取的地址
//     input wire          en,               // 开始读取信号
//     output reg [1024:0] w_out,         // 读取的数据输出
//     output reg [1024:0] a_out,         // 读取的数据输出
//     output reg          data_valid,             // 数据有效信号
//     output reg          done                    // 读取完成信号
// );

//     reg [1023:0] a_buffer [0:63];            // 假设每个缓冲区有64个1024位的数据
//     reg [1023:0] w_buffer [0:63];

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             w_out       <= 1024'b0;
//             a_out       <= 1024'b0;
//             data_valid  <= 1'b0;
//             done        <= 1'b0;
//         end else if (en) begin
//             w_out       <= w_buffer[w_read_address];
//             a_out       <= a_buffer[a_read_address];
//             data_valid  <= 1'b1;
//             done        <= 1'b1;
//         end else begin
//             data_valid <= 1'b0;
//             done <= 1'b0;
//         end
//     end

// endmodule
