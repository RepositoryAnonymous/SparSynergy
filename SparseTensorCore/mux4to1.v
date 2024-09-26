`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/05 12:43:38
// Design Name: 
// Module Name: mux4to1
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

module mux4to1 (
    input [7:0] in0,    //  
    input [7:0] in1,    //  
    input [7:0] in2,    //  
    input [7:0] in3,    //  
    input [1:0] sel,    //  
    output reg [7:0] out  // 
);

always @(*) begin
    case (sel)
        2'b00: out = in0;  //  
        2'b01: out = in1;  //  
        2'b10: out = in2;  //  
        2'b11: out = in3;  //  
        default: out = 8'b0;   
    endcase
end

endmodule