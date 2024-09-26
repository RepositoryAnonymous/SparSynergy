module PE_array(
    input wire 				clk,
    input wire 				rst,
    input wire [1023:0] 	activations,      // 4*8*8 activations * 4row
    input wire 				activation_valid,
    input wire [1023:0] 	weight_column,     // 4*1*8 weight col * 32col
    input wire      		weight_sign_en,
    input wire 				weight_valid,
    input wire [383:0] 		shift_offset,      // 4*3shift * 32col
    input wire [1:0] 		acc_en,             // for all accumulators
    input wire [31:0]       zcip_done,
    output wire [8191:0] 	result,     // 4 rows * 32 columns * 64bits
    // output wire [255:0] 	status,     // 4 rows * 32 columns * 2bit
    output wire [127:0]		done         // 4 rows * 32 columns
);

genvar i, j;
generate
    for (i = 0; i < 4; i = i + 1) begin : row_gen
        for (j = 0; j < 32; j = j + 1) begin : col_gen
            PE PE_inst (
                .clk               (clk),
                .rst               (rst),
                .activations       (activations[i*256+255 : i*256]),            //  
                .activation_valid  (activation_valid),
                .weight_column     (weight_column[j*32+31 : j*32]),          // 
                .weight_sign_en    (weight_sign_en),            //  
                .weight_valid      (weight_valid),
                .shift_offset      (shift_offset[j*12+11 : j*12]),           //  
                .acc_en            (acc_en),                 //  
                .zcip_done         (zcip_done[j]),
                .result            (result[(i*32+j)*64+63 : (i*32+j)*64]),              //  
                // .status            (status[(i*32+j)*2+1 : (i*32+j)*2]),              //  
                .done              (done[i*32+j])                 //  
            );
        end
    end
endgenerate

endmodule
