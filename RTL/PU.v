`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:49:18 PM
// Design Name: 
// Module Name: PU
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


module MAC_quantize
#(parameter DATA_WIDTH = 8,
            SCALE_WIDTH = 16
)
(
    input                           iClk,
    input                           iRst,
    input        [4:0]              iNum_bit,
    input signed [DATA_WIDTH+1-1:0]   iZero_point_MAC,
    input signed [DATA_WIDTH-1:0]   iZero_point_quant,
    input        [SCALE_WIDTH-1:0]  iScale,
    input signed [DATA_WIDTH-1:0]   iS0,
    input signed [DATA_WIDTH-1:0]   iS1,
    input signed [DATA_WIDTH*2-1:0]   iS2,
    input                           iS0_valid,
    input                           iS1_valid,
    input                           iS2_valid,
    input                           iReLU_en,
    output signed [DATA_WIDTH-1:0]  oQ0,
    output                          oQ0_valid
);
    
    wire signed [DATA_WIDTH*3-1:0] D0;
    wire D0_valid;
    wire signed [DATA_WIDTH-1:0] Q0;
    
    reg Q0_valid;
    reg [4:0] num_bit;
    reg [SCALE_WIDTH-1:0] scale;
    reg signed [DATA_WIDTH-1:0] zero_point;
    reg ReLU_en;
    
    MAC MAC_element (
        .iClk(iClk),
        .iRst(iRst),
        .iS0(iS0),
        .iS1(iS1),
        .iS2(iS2),
        .iReLU_en(iReLU_en),
        .iZero_point(iZero_point_MAC),
        .iS0_valid(iS0_valid),
        .iS1_valid(iS1_valid),
        .iS2_valid(iS2_valid),
        .oD0(D0),
        .oD0_valid(D0_valid)
    );

    quantize quantize_element(
        .iClk(iClk),
        .iRst(iRst),
        .iR(D0),
//        .iReLU_en(ReLU_en),
        .iNum_bit(num_bit),       
        .iScale(scale), 
        .iZero_point(zero_point),
        .oQ(Q0)
    );
    
    assign oQ0 = Q0;
    assign oQ0_valid = Q0_valid;
    
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            Q0_valid <= 0;
            num_bit <= 0;
            scale <= 0;
            zero_point <= 0;
            ReLU_en <= 0;
        end
        else begin
            Q0_valid <= D0_valid;
            num_bit <= iNum_bit;
            scale <= iScale;
            zero_point <= iZero_point_quant;
            ReLU_en <= iReLU_en;
        end
    end
endmodule

module PU
# (parameter DATA_WIDTH = 8,
             SCALE_WIDTH = 16
)
(   
    input iClk,
    input iRst,
    input iMode, // 0 for MAC, 1 for MAX
    input iReLU_en,
    input iPU_en,
    input signed [DATA_WIDTH-1+1:0]  iZero_point_MAC,
    input signed [DATA_WIDTH-1:0]  iZero_point_quant,
    input        [SCALE_WIDTH-1:0] iScale,
    input        [4:0]             iNum_bit,
    input signed [DATA_WIDTH-1:0]  iS0,iS1,
    input signed [DATA_WIDTH*2-1:0] iS2,
    input iS0_valid,iS1_valid,iS2_valid,
    output signed [DATA_WIDTH-1:0] oD0,
    output oD0_valid
);
    
    reg mode1, mode2;
    reg PU_en_1_reg, PU_en_2_reg;
    
    wire [DATA_WIDTH-1:0]S2_max;

    wire [DATA_WIDTH-1:0]D0_wire;
    wire D0_valid_wire;

    wire signed [DATA_WIDTH-1:0] mac_Q0;
    wire mac_Q0_valid;

    wire signed [DATA_WIDTH-1:0] max_d0;
    wire max_d0_valid;   
    
    assign S2_max = iS2[DATA_WIDTH-1:0];
    
    assign D0_wire = (mode2) ? max_d0 : mac_Q0;
    assign D0_valid_wire = (mode2) ? max_d0_valid : mac_Q0_valid;
    
    assign oD0 = (PU_en_2_reg) ? D0_wire : 0;
    assign oD0_valid = (PU_en_2_reg) ? D0_valid_wire : 0;
    
    MAC_quantize MAC_element(
        .iClk       (iClk),
        .iRst       (iRst),
        .iScale     (iScale),
        .iZero_point_MAC(iZero_point_MAC),
        .iZero_point_quant(iZero_point_quant),
        .iNum_bit   (iNum_bit),
        .iS0        (iS0),
        .iS1        (iS1),
        .iS2        (iS2),
        .iReLU_en   (iReLU_en),
        .iS0_valid  (iS0_valid),
        .iS1_valid  (iS1_valid),
        .iS2_valid  (iS2_valid),
        .oQ0        (mac_Q0),
        .oQ0_valid  (mac_Q0_valid)
    );
    
    max MAX_module(
        .iClk       (iClk),
        .iRst       (iRst),
        .iS0_valid  (iS0_valid),
        .iS0        (iS0),
        .iS1_valid  (iS1_valid),
        .iS1        (iS1),
        .iS2_valid  (iS2_valid),
        .iS2        (S2_max),
        .oD0_valid  (max_d0_valid),
        .oD0        (max_d0)
    );
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            mode1 <= 0;
            mode2 <= 0;
            PU_en_1_reg <= 0;
            PU_en_2_reg <= 0;
        end
        else begin
            mode1 <= iMode;
            mode2 <= mode1;
            PU_en_1_reg <= iPU_en;
            PU_en_2_reg <= PU_en_1_reg;
        end
    end  
endmodule
