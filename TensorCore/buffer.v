`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 16:54:25
// Design Name: 
// Module Name: buffer
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


module buffer #(
    parameter DATA_WIDTH = 64,    //  
    parameter BUFFER_DEPTH = 64,  //  
    parameter ADDR_WIDTH = 64
)(
    input  wire                         clk,            
    input  wire                         rst,            
    input  wire                         wr_en,          
    input  wire                         rd_en,          
    input  wire [DATA_WIDTH-1:0]        data_in,        
    input  wire [ADDR_WIDTH-1:0]        rd_addr,     
    input  wire [ADDR_WIDTH-1:0]        wr_addr,     
    output wire [DATA_WIDTH-1:0]        data_out,    
    output reg                          ready           
);

    //  
    reg [DATA_WIDTH-1:0] buffer_mem [0:BUFFER_DEPTH-1]; //  
    integer i;

    // 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready <= 0;
            for (i=0; i<BUFFER_DEPTH; i = i+1) begin
                buffer_mem[i] <= 0;
            end
        end else if (wr_en) begin
            buffer_mem[wr_addr] <= data_in;
            ready <= 1;
        end
    end

    //  
    assign data_out = (rd_en)? buffer_mem[rd_addr] : 0;

endmodule

