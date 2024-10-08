`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 10:55:12
// Design Name: 
// Module Name: Dispatcher
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


module Dispatcher(
    input wire          clk,
    input wire          rst,
    input wire [1:0]    a_mode,         //  
    input wire [1:0]    w_mode,         //  
    input wire [5:0]    w_read_address,    //  
    input wire [5:0]    a_read_address,    //  
    input wire          en,               //  
    input wire [5:0]    w_write_address,
    input wire [5:0]    a_write_address,
    input wire          wen,            
    input wire [1023:0] w_in,
    input wire [1023:0] a_in,          //  
    output reg [1023:0] activations,  //  
    output reg          activation_valid,          //  
    output reg [1023:0] weight_columns,
    output reg          weight_valid,
    output reg          empty,
    output reg          index_en,
    output reg          done                       //  
);

    reg [1023:0] w_buffer [0:1];   //
    reg [1023:0] a_buffer [0:1];
    integer i;
    
    reg [1023:0] w_in_buffer;           // data buffer
    reg [1023:0] a_in_buffer;           // data buffer
    reg          data_valid;
    reg [1:0]    a_mode_reg;
    reg [1:0]    w_mode_reg;
    reg          update_index;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            w_in_buffer <= 1024'b0;
            a_in_buffer <= 1024'b0;
            data_valid  <= 1'b0;
            a_mode_reg  <= 2'b0;
            w_mode_reg  <= 2'b0;
            empty       <= 1;
            index_en    <= 0;
            update_index <= 0;
            for (i = 0; i < 2; i = i + 1) begin
                w_buffer[i] <= 1024'b0;
                a_buffer[i] <= 1024'b0;
            end
        end else begin
            if (wen) begin
                w_buffer[w_write_address] <= w_in;
                a_buffer[a_write_address] <= a_in;
                data_valid  <= 1'b0;
                empty <= 0;
                update_index <= 1;
            end else if (en) begin
                w_in_buffer <= w_buffer[w_read_address];
                a_in_buffer <= a_buffer[a_read_address];
                data_valid  <= 1'b1;
                a_mode_reg  <= a_mode;
                w_mode_reg  <= w_mode;
            end else if (update_index) begin
                index_en <= 1;
                update_index <= 0;
            end else begin
                data_valid  <= 1'b0;
            end
        end
    end

    // always @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         w_in_buffer <= 1024'b0;
    //         a_in_buffer <= 1024'b0;
    //         data_valid  <= 1'b0;
    //         a_mode_reg  <= 2'b0;
    //         w_mode_reg  <= 2'b0;
    //         empty       <= 1;
    //         index_en    <= 0;
    //         update_index <= 0;
    //     end else if (wen) begin
    //         w_buffer[w_write_address]<= w_in;
    //         a_buffer[a_write_address]<= a_in;
    //         data_valid  <= 1'b0;
    //         empty <= 0;
    //         update_index <= 1;
    //     end else if (en) begin
    //         w_in_buffer <= w_buffer[w_read_address];
    //         a_in_buffer <= a_buffer[a_read_address];
    //         data_valid  <= 1'b1;
    //         a_mode_reg  <= a_mode;
    //         w_mode_reg  <= w_mode;
    //     end else if(update_index) begin
    //         index_en <= 1;
    //         update_index <= 0;
    //     end else begin
    //         data_valid  <= 1'b0;
    //     end
    // end
    

    reg [1023:0]   activations_t;
    reg [1023:0]   weight_columns_t;

    always@(*) begin
        case (a_mode_reg)
            2'b00: activations_t = a_in_buffer;
            2'b01: activations_t = {{4{a_in_buffer[255:192]}}, {4{a_in_buffer[191:128]}}, {4{a_in_buffer[127:64]}}, {4{a_in_buffer[63:0]}}};
            2'b10: activations_t = {4{a_in_buffer[255:0]}};
            2'b11: activations_t = {16{a_in_buffer[63:0]}};
        endcase

        case (w_mode_reg)
            2'b00: weight_columns_t = w_in_buffer;
            2'b01: weight_columns_t = {{4{w_in_buffer[255:192]}}, {4{w_in_buffer[191:128]}}, {4{w_in_buffer[127:64]}}, {4{w_in_buffer[63:0]}}};
            2'b10: weight_columns_t = {4{w_in_buffer[255:0]}};
            2'b11: weight_columns_t = {16{w_in_buffer[63:0]}};
        endcase
    end

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            activations         <= 0;
            activation_valid    <= 0;
            weight_columns      <= 0;
            weight_valid        <= 0;
            done                <= 0;
        end
        else begin
            activations         <= activations_t;
            activation_valid    <= data_valid;
            weight_columns      <= weight_columns_t;
            weight_valid        <= data_valid;
            done                <= data_valid;
        end
    end

endmodule
