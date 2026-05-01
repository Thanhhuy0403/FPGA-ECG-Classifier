`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:46:47 PM
// Design Name: 
// Module Name: Quantize
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


module quantize (
    input                iClk,
    input                iRst,
    input  signed [23:0] iR,
    input         [4:0]  iNum_bit,       
    input         [15:0] iScale, 
    input  signed [7:0] iZero_point,
//    input                iReLU_en,
    output signed [7:0] oQ
);
   
    wire signed [39:0] parity_0;
    wire signed [39:0] parity_1;
    wire signed [39:0] parity_2;
    wire signed [39:0] parity_3;
    wire signed [39:0] parity_4;
    wire signed [39:0] parity_5;
    wire signed [39:0] parity_6;
    wire signed [39:0] parity_7;
    wire signed [39:0] parity_8;
    wire signed [39:0] parity_9;
    wire signed [39:0] parity_10;
    wire signed [39:0] parity_11;
    wire signed [39:0] parity_12;
    wire signed [39:0] parity_13;
    wire signed [39:0] parity_14;
    wire signed [39:0] parity_15;
    
    wire [23:0] R_abs;
    wire R_signed;
    wire signed [15:0] multicand;
    wire [39:0] multiplier;
    wire  [39:0] sum_stage_1;
    wire  [39:0] sum_stage_2;
    wire signed [39:0] sum_final;
    
    wire signed [39:0] Q_wire;
    wire signed [7:0]  Q_out;
    
    reg R_signed_reg;
    reg [4:0]  num_bit_reg;
    reg signed [7:0] zero_point_reg;
    reg signed [15:0] multicand_reg;
    reg [39:0] multiplier_reg;
    reg signed [39:0] sum_stage_1_reg;

    assign R_signed = iR[23];
    assign R_abs = R_signed ? -iR : iR;
    assign multiplier = {16'b0,R_abs};
    assign multicand = iScale;
    
    assign parity_0 = multicand[0] ? multiplier << 0 : 0;
    assign parity_1 = multicand[1] ? multiplier << 1 : 0;
    assign parity_2 = multicand[2] ? multiplier << 2 : 0; 
    assign parity_3 = multicand[3] ? multiplier << 3 : 0;
    assign parity_4 = multicand[4] ? multiplier << 4 : 0;
    assign parity_5 = multicand[5] ? multiplier << 5 : 0;
    assign parity_6 = multicand[6] ? multiplier << 6 : 0;
    assign parity_7 = multicand[7] ? multiplier << 7 : 0;
    assign parity_8 = multicand[8] ? multiplier << 8 : 0;
    assign parity_9 = multicand[9] ? multiplier << 9 : 0;       
    
    assign sum_stage_1 = parity_0 + parity_1 + parity_2 + parity_3 + parity_4 + 
                         parity_5 + parity_6 + parity_7 + parity_8 + parity_9;
    
    assign parity_10 = multicand_reg[10] ? multiplier_reg << 10 : 0;
    assign parity_11 = multicand_reg[11] ? multiplier_reg << 11 : 0;
    assign parity_12 = multicand_reg[12] ? multiplier_reg << 12 : 0;
    assign parity_13 = multicand_reg[13] ? multiplier_reg << 13 : 0;
    assign parity_14 = multicand_reg[14] ? multiplier_reg << 14 : 0;
    assign parity_15 = multicand_reg[15] ? multiplier_reg << 15 : 0;
    
    assign sum_stage_2 = sum_stage_1_reg + parity_10 + parity_11 + parity_12 + 
                         parity_13 + parity_14 + parity_15; 
                       
    assign sum_final = R_signed_reg ? -sum_stage_2 : sum_stage_2; 
    assign Q_wire = (sum_final >>> num_bit_reg) + sum_final[num_bit_reg-1]; 
    assign Q_out = /*(Q_wire > 127)  ? 127  : (Q_wire < -128) ? -128 : */Q_wire[7:0] - 128;
    assign oQ    = /*(iReLU_en && Q_out < -128) ? -128 :*/ Q_out; 
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            multicand_reg <= 0;
            multiplier_reg <= 0;
            zero_point_reg <=0;
            num_bit_reg <= 0;
            sum_stage_1_reg <= 0;
            R_signed_reg <= 0;
        end
        else begin
            multicand_reg <= multicand;
            zero_point_reg <= iZero_point;
            num_bit_reg <= iNum_bit;
            multiplier_reg <= multiplier;
            sum_stage_1_reg <= sum_stage_1;
            R_signed_reg <= R_signed;
        end
    end   
endmodule
