`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 10:49:26
// Design Name: 
// Module Name: ZCIP_array
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


module ZCIP_array(
    input wire clk,
    input wire rst,
    input wire [223:0] index_vector,  //  
    output wire [95:0] shift_offset, //  
    output wire [31:0]  valid,              //  
    output wire [31:0]  done                //  
);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : zcip_gen
        ZCIP zcip_inst (
            .clk          (clk),
            .rst          (rst),
            .index_vector (index_vector[i*7+6 : i*7]),  // 
            .shift_offset (shift_offset[i*3+2 : i*3]),  // 
            .valid        (valid[i]),         //  
            .done         (done[i])           //  
        );
    end
endgenerate

endmodule

