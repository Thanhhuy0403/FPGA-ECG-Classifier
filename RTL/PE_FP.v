`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 10:40:29 PM
// Design Name: 
// Module Name: PE_FP
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

module PE_FP 
# (parameter DATA_WIDTH = 8,
             ADDR_WIDTH = 8,
             LDM_NUM_BITS = 2,
             PE_NO = 0
)
(
    input iClk,
    input iRst,
    // PU inputs
    input iPU_en,
    input iMode, // 0 for MAC, 1 for MAX
    input iReLU_en,
    input [1:0]iCfg,
    input iIncrement_en,
    input signed [DATA_WIDTH-1+1:0]  iZero_point_MAC,    
    input signed [DATA_WIDTH-1:0]  iZero_point_quant,
    input        [15:0]            iScale,
    input        [4:0]             iNum_bit,
    input        [DATA_WIDTH-1:0]  iWeight,
    input        iWeight_en,
    input        [DATA_WIDTH*2-1:0]  iBias,
    input        iBias_en,
    input        [DATA_WIDTH-1:0]  iPixel0_buffer2PE,
    input        iPixel0_buffer2PE_valid,
    input        [DATA_WIDTH-1:0]  iPixel1_buffer2PE,
    input        iPixel1_buffer2PE_valid,
    input        [DATA_WIDTH-1:0]  iPixel2_buffer2PE,
    input        iPixel2_buffer2PE_valid,
    // LSU inputs
    input        iPadding_en,
    input        [DATA_WIDTH-1:0]  iData_a,
    input        iEn_a, 
    input        iWrite_en_a,
    input        [4+LDM_NUM_BITS+ADDR_WIDTH-1:0]  iAddr_a,
    input        [LDM_NUM_BITS+ADDR_WIDTH-1:0]  iCTRL_Addr_a,
    input        [LDM_NUM_BITS+ADDR_WIDTH-1:0]  iCTRL_Addr_b,
    input        iCTRL_write_en_a,
    input        iCTRL_write_en_b,
    input        iCTRL_en_a,
    input        iCTRL_en_b,

    input [LDM_NUM_BITS+ADDR_WIDTH-1:0] iALU_Addr_Store,
    input iLayer_done,

    output       [DATA_WIDTH-1:0]  oPixel_0,
    output       oPixel_valid_0,
    output       [DATA_WIDTH-1:0]  oPixel_1,
    output       oPixel_valid_1,
    output       [DATA_WIDTH-1:0] oData_Pixel
);
    
    localparam MAC = 2'b00;
    localparam MAX = 2'b01;
    localparam ADD = 2'b10;

    wire signed [DATA_WIDTH-1:0] PU_S0;
    wire PU_S0_valid;
    wire signed [DATA_WIDTH-1:0] PU_S1;
    wire PU_S1_valid;
    wire signed [DATA_WIDTH*2-1:0] PU_S2;
    wire PU_S2_valid;
    wire signed [DATA_WIDTH-1:0] ALU_out;
    wire ALU_out_valid;
    wire [LDM_NUM_BITS+ADDR_WIDTH-1:0] ALU_LDM_addr;
    wire [LDM_NUM_BITS+ADDR_WIDTH-1:0] CTRL_Addr_a;
    wire [LDM_NUM_BITS+ADDR_WIDTH-1:0] CTRL_Addr_b;
    wire AXI_LDM_ena_wr;
    reg [DATA_WIDTH-1:0] ALU_LDM_addr_reg;
    reg Pixel_0_valid_reg;
    reg layer_done1;
    reg layer_done2;
    
    assign AXI_LDM_ena_wr = (iAddr_a[4+LDM_NUM_BITS+ADDR_WIDTH-1:LDM_NUM_BITS+ADDR_WIDTH] == PE_NO) ? iEn_a: 1'b0;
    assign PU_S0 = iPixel0_buffer2PE;
    assign PU_S0_valid = (layer_done2) ? 0 : iPixel0_buffer2PE_valid ;
    assign PU_S1 = (iCfg == MAC) ? iWeight : iPixel1_buffer2PE;
    assign PU_S1_valid = (layer_done2) ? 0 : (iCfg == MAC) ? iWeight_en  : iPixel1_buffer2PE_valid ;
    assign PU_S2 = (iCfg == MAC) ? iBias : {{DATA_WIDTH{1'b0}},iPixel2_buffer2PE};
    assign PU_S2_valid = (layer_done2) ? 0 : (iCfg == MAC) ? iBias_en  : iPixel2_buffer2PE_valid ;   
    PU PU_element (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(iPU_en),
        .iMode(iMode), // 0 for MAC, 1 for MAX
        .iReLU_en(iReLU_en),
        .iZero_point_quant(iZero_point_quant),
        .iZero_point_MAC (iZero_point_MAC),
        .iScale(iScale),
        .iNum_bit(iNum_bit),
        .iS0(PU_S0),
        .iS1(PU_S1),
        .iS2(PU_S2),
        .iS0_valid(PU_S0_valid),
        .iS1_valid(PU_S1_valid),
        .iS2_valid(PU_S2_valid),
        .oD0(ALU_out),
        .oD0_valid(ALU_out_valid)
    );
    
 
    assign CTRL_Addr_a = iCTRL_Addr_a + iIncrement_en;
    assign CTRL_Addr_b = iCTRL_Addr_b + iIncrement_en;
    assign ALU_LDM_addr = iALU_Addr_Store + ALU_LDM_addr_reg;

    LSU_FP LSU_element(
        .iClk(iClk),
        .iRst(iRst),
        .iPadding_en(iPadding_en),
        .iIncrement_en(iIncrement_en),
        .iData_a(iData_a),
        .iZero_point_MAC(iZero_point_MAC),        
        .iEn_a(AXI_LDM_ena_wr),
        .iWrite_en_a(iWrite_en_a),
        .iAddr_a(iAddr_a[LDM_NUM_BITS + ADDR_WIDTH-1:0]),
        .iCTRL_Addr_a(CTRL_Addr_a),
        .iCTRL_Addr_b(CTRL_Addr_b),
        .iCTRL_write_en_a(iCTRL_write_en_a),
        .iCTRL_write_en_b(iCTRL_write_en_b),
        .iCTRL_en_a(iCTRL_en_a),
        .iCTRL_en_b(iCTRL_en_b),
        .iALU_Addr_b(ALU_LDM_addr),
        .iALU_Data_b(ALU_out),
        .iALU_en_b(ALU_out_valid && iPU_en),
        .iALU_write_en_b(ALU_out_valid && iPU_en),
        .oPixel_0(oPixel_0),
        .oPixel_valid_0(oPixel_valid_0),
        .oPixel_1(oPixel_1),
        .oPixel_valid_1(oPixel_valid_1),
        .oData_Pixel(oData_Pixel)
    );
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            ALU_LDM_addr_reg <= 8'hff;
            Pixel_0_valid_reg <= 0;
            layer_done1 <= 0;
            layer_done2 <= 0;
        end
        else begin
 
            layer_done1 <= iLayer_done;
            layer_done2 <= layer_done1;
            
            if (iLayer_done) begin
                ALU_LDM_addr_reg <= 8'hff;
                Pixel_0_valid_reg <= 0;
            end
            else if (iPU_en) begin
                Pixel_0_valid_reg <= PU_S0_valid;
                if (iCfg == MAC) begin
                    ALU_LDM_addr_reg <= ALU_LDM_addr_reg + iBias_en;
                end
                else begin
                    ALU_LDM_addr_reg <= ALU_LDM_addr_reg + Pixel_0_valid_reg;
                end
            end                
        end
    end

endmodule
