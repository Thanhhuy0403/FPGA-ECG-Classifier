`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:41:21 PM
// Design Name: 
// Module Name: MAC
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


module MAC 
#(parameter DATA_WIDTH = 8
)
(
    input                          iClk,
    input                          iRst,
    input  signed [DATA_WIDTH-1:0] iS0,
    input  signed [DATA_WIDTH-1:0] iS1,
    input  signed [DATA_WIDTH-1+1:0] iZero_point,
    input  signed [DATA_WIDTH*2-1:0] iS2,
    input iReLU_en,  
//______________________Enable and valid signal_________________________              
    input                          iS0_valid,
    input                          iS1_valid,
    input                          iS2_valid,
    output reg signed [DATA_WIDTH*3-1:0] oD0,
    output reg                        oD0_valid
);
/*_________________________REG SIGNAL_____________________________*/    
    reg signed [DATA_WIDTH*3-1:0] accumulation_reg;
/*_______________________WIRE SIGNAL___________________________*/    
    wire signed [DATA_WIDTH*3-1:0] accumulation_wire;
    wire signed [DATA_WIDTH*2-1+1:0] mul_wire;
    wire signed [DATA_WIDTH*2-1+1:0] parity_0;
    wire signed [DATA_WIDTH*2-1+1:0] parity_1;
    wire signed [DATA_WIDTH*2-1+1:0] parity_2;
    wire signed [DATA_WIDTH*2-1+1:0] parity_3;
    wire signed [DATA_WIDTH*2-1+1:0] parity_4;
    wire signed [DATA_WIDTH*2-1+1:0] parity_5;
    wire signed [DATA_WIDTH*2-1+1:0] parity_6;
    wire signed [DATA_WIDTH*2-1+1:0] parity_7;
    wire signed [DATA_WIDTH*2-1+1:0] parity_8;
//    wire signed [DATA_WIDTH*2-1:0] 
//    wire signed [DATA_WIDTH*2-1:0] sum_wire;
    wire signed [DATA_WIDTH-1+1:0]   abs_S0_wire;
    wire signed [DATA_WIDTH-1+1:0]   S0_add_zp;
    wire signed [DATA_WIDTH-1+1:0]   abs_S1_wire;
    wire signed [DATA_WIDTH*2-1:0]   bias_wire;
    wire signed [DATA_WIDTH*2-1:0] extend_abs_S1;
    wire                           same_signed;
    wire signed [DATA_WIDTH*2-1+1:0] final_mul;
    wire signed [DATA_WIDTH*3-1:0] D0_ReLU;
    
    assign S0_add_zp = {iS0[7],iS0[7:0]} + iZero_point;
    assign abs_S0_wire = (S0_add_zp[DATA_WIDTH-1+1:DATA_WIDTH-1+1]) ? -S0_add_zp : S0_add_zp;
    assign abs_S1_wire = (iS1[DATA_WIDTH-1:DATA_WIDTH-1]) ? -iS1 : iS1; 
    assign extend_abs_S1 = {8'b0,abs_S1_wire}; 
    assign bias_wire = (iS2_valid) ? iS2 : 0;
    assign same_signed = ~(iS1[DATA_WIDTH-1:DATA_WIDTH-1] ^ S0_add_zp[DATA_WIDTH-1+1:DATA_WIDTH-1+1]);
      
    assign parity_0 = abs_S0_wire[0] ? extend_abs_S1 << 0 : 0;
    assign parity_1 = abs_S0_wire[1] ? extend_abs_S1 << 1 : 0;
    assign parity_2 = abs_S0_wire[2] ? extend_abs_S1 << 2 : 0;
    assign parity_3 = abs_S0_wire[3] ? extend_abs_S1 << 3 : 0;
    assign parity_4 = abs_S0_wire[4] ? extend_abs_S1 << 4 : 0;
    assign parity_5 = abs_S0_wire[5] ? extend_abs_S1 << 5 : 0;
    assign parity_6 = abs_S0_wire[6] ? extend_abs_S1 << 6 : 0;
    assign parity_7 = abs_S0_wire[7] ? extend_abs_S1 << 7 : 0;
    assign parity_8 = abs_S0_wire[8] ? extend_abs_S1 << 8 : 0;    
            
    assign mul_wire = parity_0 + parity_1 + parity_2 + parity_3 + parity_4
                               + parity_5 + parity_6 + parity_7;
    assign final_mul = (same_signed) ? mul_wire : -mul_wire;
    assign accumulation_wire = final_mul + bias_wire + accumulation_reg;
    assign D0_ReLU = (iReLU_en && accumulation_wire < 0) ? 0 : accumulation_wire;
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin 
            accumulation_reg <= 0;
            oD0 <= 0;
            oD0_valid <= 0;
        end 
        else begin
            oD0      <= D0_ReLU;
            oD0_valid<= iS2_valid;
            if (iS2_valid) begin
                accumulation_reg <= 0;
            end
            else if (iS0_valid | iS1_valid) begin
                accumulation_reg <= accumulation_wire;
            end
            else begin 
                accumulation_reg <= 0;
            end
        end
    end  
endmodule