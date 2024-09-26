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
//     input wire [5:0]    w_read_address,    //  
//     input wire [5:0]    a_read_address,    //  
//     input wire          en,               //  
//     output reg [1024:0] w_out,         // 
//     output reg [1024:0] a_out,         //  
//     output reg          data_valid,             //  
//     output reg          done                    //  
// );

//     reg [1023:0] a_buffer [0:63];            //  
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
