`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/06 09:57:05
// Design Name: 
// Module Name: mux4to2
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


module mux4to2(
	input wire [7:0] in0,    //  
    input wire [7:0] in1,    //  
    input wire [7:0] in2,    //  
    input wire [7:0] in3,    //  
    input wire [3:0] sel,    //  
	output wire [7:0] out0, //  
	output wire [7:0] out1
    );

	mux4to1 mux0(
    	.in0	(in0),    //  
    	.in1	(in1),    //  
    	.in2	(in2),    //  
    	.in3	(in3),    //  
    	.sel	(sel[1:0]),   
    	.out	(out0)  //   
	);

	mux4to1 mux1(
    	.in0	(in0),    //  
    	.in1	(in1),    //  
    	.in2	(in2),    //  
    	.in3	(in3),    //  
    	.sel	(sel[3:2]),   
    	.out	(out1)  //   
	);

endmodule
