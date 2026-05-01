`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2026 10:29:18 AM
// Design Name: 
// Module Name: CNN_Core
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

module CNN_Core
# (parameter DATA_WIDTH = 8,
             SCALE_WIDTH = 29,
             WEIGHT_ADDR_WIDTH = 13,
             SCALE_ADDR_WIDTH = 8,
             BIAS_ADDR_WIDTH = 8,
             CTX_ADDR_WIDTH = 6,
             CTX_WIDTH = 30,
             PE_NUM = 10,
             PE_NUM_BITS = 4,
             LDM_NUM_BITS = 2,
             LDM_ADDR_WIDTH = 8
             
)             
(
    input iClk,
    input iRst,
    input iStart,
    
    input [DATA_WIDTH-1:0] iECG_signal,
    input [PE_NUM_BITS + LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0]iECG_LDM_addr,
    input iECG_LDM_en_a,
    input iECG_LDM_write_en_a,
    
    input [CTX_WIDTH-1:0] iCtx,
    input [CTX_ADDR_WIDTH-1:0] iCtx_addr,
    input iCtx_en,
    input iCtx_write_en,
    
    input [WEIGHT_ADDR_WIDTH-1:0] iWeight_addr,
    input [DATA_WIDTH-1:0] iWeight,
    input iWeight_en,
    input iWeight_write_en,
    
    input [SCALE_ADDR_WIDTH-1:0] iScale_addr,
    input [SCALE_WIDTH-1:0] iScale,
    input iScale_en,
    input iScale_write_en,
    
    input [BIAS_ADDR_WIDTH-1:0] iBias_addr,
    input [DATA_WIDTH*2-1:0] iBias,
    input iBias_en,
    input iBias_write_en,
    
    output oDone,
    output [DATA_WIDTH-1:0] oData_out
    
);
    
    wire [CTX_WIDTH-1:0] context_port_a;
    wire [DATA_WIDTH-1:0] weight_port_a;
    wire [DATA_WIDTH*2-1:0] bias_port_a;
    wire [SCALE_WIDTH-1:0] scale_port_a;
    
    wire [CTX_WIDTH-1:0] context_to_controller;
    wire [CTX_ADDR_WIDTH-1:0] context_addr;
    wire context_en;
    wire context_write_en;
    
    wire [DATA_WIDTH-1:0]Data_Pixel_PE_out[PE_NUM-1:0];
    
    wire [DATA_WIDTH-1:0] weight_to_PE;
    wire [WEIGHT_ADDR_WIDTH-1:0] weight_addr;
    wire weight_en;
    wire weight_write_en;
    
    wire [DATA_WIDTH*2-1:0] bias_to_PE;
    wire [BIAS_ADDR_WIDTH-1:0] bias_addr;
    wire bias_en;
    wire bias_write_en;
    
    wire [SCALE_WIDTH-1:0] scale_to_PE;
    wire [SCALE_ADDR_WIDTH-1:0] scale_addr;
    wire scale_en;
    wire scale_write_en;    
    
    wire [PE_NUM-1:0] padding_en;
    wire [PE_NUM-1:0] increment_en;
    
    wire [LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0] CTRL_LDM_addr_a;
    wire [LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0] CTRL_LDM_addr_b;
    wire CTRL_LDM_en_a;
    wire CTRL_LDM_en_b;
    wire CTRL_LDM_write_en_a;
    wire CTRL_LDM_write_en_b;
    wire [LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0] ALU_LDM_addr_store;
    
    wire [DATA_WIDTH-1:0] Pixel_0_to_buffer [PE_NUM-1:0];
    wire [DATA_WIDTH-1:0] Pixel_1_to_buffer [PE_NUM-1:0];
    wire [PE_NUM-1:0] Pixel_0_to_buffer_valid;
    wire [PE_NUM-1:0] Pixel_1_to_buffer_valid;
    
    wire [DATA_WIDTH-1:0] Pixel_0_to_PE [PE_NUM-1:0];
    wire [DATA_WIDTH-1:0] Pixel_1_to_PE [PE_NUM-1:0];
    wire [DATA_WIDTH-1:0] Pixel_2_to_PE [PE_NUM-1:0];
    wire [PE_NUM-1:0] Pixel_0_to_PE_valid;   
    wire [PE_NUM-1:0] Pixel_1_to_PE_valid; 
    wire [PE_NUM-1:0] Pixel_2_to_PE_valid;              
    
    wire relu_en;
    wire [1:0] cfg;
    wire layer_done;
    wire PU_mode;
    wire stride;
    wire PU_en;
    wire [3:0]MUX_select;
    wire MP_padding_FP;
    wire MP_padding_LP;
    wire MP_padding_LP_First;    
    
    reg [DATA_WIDTH-1:0] weight_reg;
    reg [DATA_WIDTH*2-1:0] bias_reg;
    reg [SCALE_WIDTH-1:0] scale_reg;
    reg signed [DATA_WIDTH-1+1:0] Zero_point_MAC_reg;
    reg [SCALE_ADDR_WIDTH-1:0] scale_addr_reg;
    reg weight_valid_1;
    reg weight_valid_2;
    reg bias_valid_1;
    reg bias_valid_2;
    reg scale_valid_1;
    reg scale_valid_2;
    reg [3:0]MUX_select_reg;
    reg MP_FP_reg;
    reg MP_LP_reg;
    reg MP_LP_reg_First;
    
    
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            weight_reg <= 0;
            bias_reg <= 0;
            scale_reg <= 0;
            weight_valid_1 <= 0;
            weight_valid_2 <= 0;
            bias_valid_1 <= 0;
            bias_valid_2 <= 0;
            scale_valid_1 <= 0;
            scale_valid_2 <= 0;
          
            MUX_select_reg <= 0;
            MP_FP_reg <= 0;
            MP_LP_reg <= 0;
            MP_LP_reg_First <= 0;
            Zero_point_MAC_reg <= 0;
            scale_addr_reg <= 0;
        end
        else begin
            weight_valid_1 <= weight_en;
            weight_valid_2 <= weight_valid_1;
            bias_valid_1 <= bias_en;
            bias_valid_2 <= bias_valid_1;
            scale_valid_1 <= scale_en;
            scale_valid_2 <= scale_valid_1;
            MUX_select_reg <= MUX_select;
            MP_FP_reg <= MP_padding_FP;
            MP_LP_reg <= MP_padding_LP;
            MP_LP_reg_First <= MP_padding_LP_First;
            scale_addr_reg <= scale_addr;
            if (weight_valid_1) begin
                weight_reg <= weight_to_PE; 
            end
            else begin
                weight_reg <= 0;
            end
            if (bias_valid_1) begin
                bias_reg <= bias_to_PE;
            end
            else begin
                bias_reg <= 0;
            end
            if (scale_valid_1) begin
                scale_reg <= scale_to_PE;
            end
            else begin
                scale_reg <= 0;
            end
            if (scale_addr_reg < 8) begin
                Zero_point_MAC_reg <= -5;
            end
            else begin
                Zero_point_MAC_reg <= 128;
            end
        end
    end
    
    assign oData_out = Data_Pixel_PE_out[0] | Data_Pixel_PE_out[1] | Data_Pixel_PE_out[2] | Data_Pixel_PE_out[3] | Data_Pixel_PE_out[4] | Data_Pixel_PE_out[5] | Data_Pixel_PE_out[6] | Data_Pixel_PE_out[7] | Data_Pixel_PE_out[8] |Data_Pixel_PE_out[9];
    
    Dual_Port_RAM
    #(.DATA_WIDTH(CTX_WIDTH),
      .ADDR_WIDTH(CTX_ADDR_WIDTH))
    Context_RAM
    (
        .iClk(iClk),
        .iEn_a(iCtx_en),
        .iWrite_en_a(iCtx_write_en),
        .iAddr_a(iCtx_addr),
        .iData_a(iCtx),
        .oData_a(context_port_a),
        
        .iEn_b(context_en),
        .iWrite_en_b(context_write_en),
        .iAddr_b(context_addr),
        .iData_b(0),
        .oData_b(context_to_controller)  
    );
    Dual_Port_RAM
    #(.DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(WEIGHT_ADDR_WIDTH))
    Weight_RAM
    (
        .iClk(iClk),
        .iEn_a(iWeight_en),
        .iWrite_en_a(iWeight_write_en),
        .iAddr_a(iWeight_addr),
        .iData_a(iWeight),
        .oData_a(weight_port_a),
        
        .iEn_b(weight_en),
        .iWrite_en_b(weight_write_en),
        .iAddr_b(weight_addr),
        .iData_b(0),
        .oData_b(weight_to_PE)  
    );
    Dual_Port_RAM
    #(.DATA_WIDTH(DATA_WIDTH*2),
      .ADDR_WIDTH(BIAS_ADDR_WIDTH))
    Bias_RAM
    (
        .iClk(iClk),
        .iEn_a(iBias_en),
        .iWrite_en_a(iBias_write_en),
        .iAddr_a(iBias_addr),
        .iData_a(iBias),
        .oData_a(bias_port_a),
        
        .iEn_b(bias_en),
        .iWrite_en_b(bias_write_en),
        .iAddr_b(bias_addr),
        .iData_b(0),
        .oData_b(bias_to_PE)  
    );
    Dual_Port_RAM
    #(.DATA_WIDTH(SCALE_WIDTH),
      .ADDR_WIDTH(SCALE_ADDR_WIDTH))
    Scale_RAM
    (
        .iClk(iClk),
        .iEn_a(iScale_en),
        .iWrite_en_a(iScale_write_en),
        .iAddr_a(iScale_addr),
        .iData_a(iScale),
        .oData_a(scale_port_a),
        
        .iEn_b(scale_en),
        .iWrite_en_b(scale_write_en),
        .iAddr_b(scale_addr),
        .iData_b(0),
        .oData_b(scale_to_PE)  
    ); 
    controller
    #( .DATA_WIDTH(DATA_WIDTH),
       .WEIGHT_ADDR_WIDTH(WEIGHT_ADDR_WIDTH),
       .SCALE_ADDR_WIDTH(SCALE_ADDR_WIDTH),
       .BIAS_ADDR_WIDTH(BIAS_ADDR_WIDTH),
       .CTX_ADDR_WIDTH(CTX_ADDR_WIDTH),
       .PE_NUM(PE_NUM),
       .PE_NUM_BITS(PE_NUM_BITS),
       .LDM_ADDR_WIDTH(LDM_ADDR_WIDTH),
       .LDM_NUM_BITS(LDM_NUM_BITS)
    )
    controller 
    (
    .iClk(iClk),
    .iRst(iRst),
    .iStart(iStart),
    .iCtx(context_to_controller),

    .oWeight_addr(weight_addr),
    .oWeight_write_en(weight_write_en),
    .oWeight_en(weight_en),

    .oScale_addr(scale_addr),
    .oScale_en(scale_en),
    .oScale_write_en(scale_write_en),
    
    .oBias_addr(bias_addr),
    .oBias_write_en(bias_write_en),
    .oBias_en(bias_en),

    .oCtx_addr(context_addr),
    .oCtx_en(context_en),
    .oCtx_write_en(context_write_en),

    .oMux_select(MUX_select),

    .oLDM_addr_a(CTRL_LDM_addr_a),
    .oLDM_en_a(CTRL_LDM_en_a),
    .oCTRL_LDM_write_en_a(CTRL_LDM_write_en_a),
    .oLDM_addr_b(CTRL_LDM_addr_b),
    .oLDM_en_b(CTRL_LDM_en_b),
    .oCTRL_LDM_write_en_b(CTRL_LDM_write_en_b),
    .oALU_LDM_addr_store(ALU_LDM_addr_store),
    
    .oReLU_en(relu_en),
    .oStride(stride),
    .oPadding_en(padding_en),
    .oIncrement_addr_en(increment_en),
    .oPU_mode(PU_mode),
    .oPU_en(PU_en),
    .oCfg(cfg),
    .oLayer_done(layer_done),
    .oMP_padding_FP(MP_padding_FP),
    .oMP_padding_LP(MP_padding_LP),
    .oMP_padding_LP_First(MP_padding_LP_First),
    .oDone(oDone)
);
    PE_FP 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(0)
    )
    PE_0
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[0]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[0]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[0]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[0]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[0]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[0]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[0]),
        .iPadding_en(padding_en[0]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[0]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[0]),
        .oPixel_1(Pixel_1_to_buffer[0]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[0]),
        .oData_Pixel(Data_Pixel_PE_out[0])
    );
    
    PE_FP 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(1)
    )
    PE_1
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[1]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[1]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[1]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[1]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[1]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[1]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[1]),
        .iPadding_en(padding_en[1]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a), 
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[1]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[1]),
        .oPixel_1(Pixel_1_to_buffer[1]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[1]),
        .oData_Pixel(Data_Pixel_PE_out[1])        
    );
    
    PE_FP 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(2)      
    )
    PE_2
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[2]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[2]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[2]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[2]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[2]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[2]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[2]),
        .iPadding_en(padding_en[2]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[2]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[2]),
        .oPixel_1(Pixel_1_to_buffer[2]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[2]),
        .oData_Pixel(Data_Pixel_PE_out[2])        
    );
    PE 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(3)      
    )
    PE_3
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[3]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[3]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[3]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[3]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[3]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[3]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[3]),
        .iPadding_en(padding_en[3]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[3]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[3]),
        .oPixel_1(Pixel_1_to_buffer[3]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[3]),
        .oData_Pixel(Data_Pixel_PE_out[3])        
    );
    
    PE 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS), 
      .PE_NO(4)      
    )
    PE_4
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[4]),        
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[4]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[4]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[4]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[4]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[4]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[4]),
        .iPadding_en(padding_en[4]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[4]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[4]),
        .oPixel_1(Pixel_1_to_buffer[4]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[4]),
        .oData_Pixel(Data_Pixel_PE_out[4])        
    );  
    
    PE 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(5)       
    )
    PE_5
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[5]),        
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[5]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[5]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[5]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[5]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[5]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[5]),
        .iPadding_en(padding_en[5]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[5]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[5]),
        .oPixel_1(Pixel_1_to_buffer[5]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[5]),
        .oData_Pixel(Data_Pixel_PE_out[5])        
    );  
    
    PE 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(6)       
    )
    PE_6
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[6]),        
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[6]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[6]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[6]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[6]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[6]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[6]),
        .iPadding_en(padding_en[6]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[6]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[6]),
        .oPixel_1(Pixel_1_to_buffer[6]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[6]),
        .oData_Pixel(Data_Pixel_PE_out[6])       
    );  

    PE_LP 
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(7)       
    )
    PE_7
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[7]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[7]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[7]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[7]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[7]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[7]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[7]),
        .iPadding_en(padding_en[7]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[7]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[7]),
        .oPixel_1(Pixel_1_to_buffer[7]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[7]),
        .oData_Pixel(Data_Pixel_PE_out[7])        
    );

    PE_LP
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(8)       
    )
    PE_8
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[8]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[8]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[8]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[8]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[8]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[8]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[8]),
        .iPadding_en(padding_en[8]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[8]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[8]),
        .oPixel_1(Pixel_1_to_buffer[8]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[8]),
        .oData_Pixel(Data_Pixel_PE_out[8])        
    );        

    PE_LP
    #(.DATA_WIDTH(DATA_WIDTH) ,
      .ADDR_WIDTH(LDM_ADDR_WIDTH) ,
      .LDM_NUM_BITS(LDM_NUM_BITS),
      .PE_NO(9)       
    )
    PE_9
    (
        .iClk(iClk),
        .iRst(iRst),
        .iPU_en(PU_en),
        .iMode(PU_mode), // 0 for MAC, 1 for MAX
        .iReLU_en(relu_en),
        .iCfg(cfg),
        .iIncrement_en(increment_en[9]),
        .iZero_point_quant(scale_reg[7:0]), .iZero_point_MAC(Zero_point_MAC_reg), 
        .iScale(scale_reg[28:13]),
        .iNum_bit(scale_reg[12:8]),
        .iWeight(weight_reg),
        .iWeight_en(weight_valid_2),
        .iBias(bias_reg),
        .iBias_en(bias_valid_2),
        .iPixel0_buffer2PE(Pixel_0_to_PE[9]),
        .iPixel0_buffer2PE_valid(Pixel_0_to_PE_valid[9]),
        .iPixel1_buffer2PE(Pixel_1_to_PE[9]),
        .iPixel1_buffer2PE_valid(Pixel_1_to_PE_valid[9]),
        .iPixel2_buffer2PE(Pixel_2_to_PE[9]),
        .iPixel2_buffer2PE_valid(Pixel_2_to_PE_valid[9]),
        .iPadding_en(padding_en[9]),
        .iData_a(iECG_signal),
        .iEn_a(iECG_LDM_en_a),
        .iWrite_en_a(iECG_LDM_write_en_a),
        .iAddr_a(iECG_LDM_addr),
        .iCTRL_Addr_a(CTRL_LDM_addr_a),
        .iCTRL_Addr_b(CTRL_LDM_addr_b),
        .iCTRL_write_en_a(CTRL_LDM_write_en_a),
        .iCTRL_write_en_b(CTRL_LDM_write_en_b),
        .iCTRL_en_a(CTRL_LDM_en_a),
        .iCTRL_en_b(CTRL_LDM_en_b),
        .iALU_Addr_Store(ALU_LDM_addr_store),
        .iLayer_done(layer_done),
        .oPixel_0(Pixel_0_to_buffer[9]),
        .oPixel_valid_0(Pixel_0_to_buffer_valid[9]),
        .oPixel_1(Pixel_1_to_buffer[9]),
        .oPixel_valid_1(Pixel_1_to_buffer_valid[9]),
        .oData_Pixel(Data_Pixel_PE_out[9])        
    );
    
    pixel_buffer
    #(.DATA_WIDTH(DATA_WIDTH))
    Global_buffer
    ( 
        .iClk(iClk),
        .iRst(iRst),
        .iCfg(cfg),
        .iStride(stride),
        .iMUX_Sel(MUX_select_reg),
        .iMP_FP(MP_FP_reg),
        .iMP_LP(MP_LP_reg),
        .iMP_LP_First(MP_LP_reg_First),
        
        .iPixel_0_PE_0(Pixel_0_to_buffer[0]),
        .iPixel_0_PE_1(Pixel_0_to_buffer[1]),
        .iPixel_0_PE_2(Pixel_0_to_buffer[2]),
        .iPixel_0_PE_3(Pixel_0_to_buffer[3]),
        .iPixel_0_PE_4(Pixel_0_to_buffer[4]),
        .iPixel_0_PE_5(Pixel_0_to_buffer[5]),
        .iPixel_0_PE_6(Pixel_0_to_buffer[6]),
        .iPixel_0_PE_7(Pixel_0_to_buffer[7]),
        .iPixel_0_PE_8(Pixel_0_to_buffer[8]),
        .iPixel_0_PE_9(Pixel_0_to_buffer[9]),
                             
        
        .iPixel_1_PE_0(Pixel_1_to_buffer[0]),
        .iPixel_1_PE_1(Pixel_1_to_buffer[1]),
        .iPixel_1_PE_2(Pixel_1_to_buffer[2]),
        .iPixel_1_PE_3(Pixel_1_to_buffer[3]),
        .iPixel_1_PE_4(Pixel_1_to_buffer[4]),
        .iPixel_1_PE_5(Pixel_1_to_buffer[5]),
        .iPixel_1_PE_6(Pixel_1_to_buffer[6]),
        .iPixel_1_PE_7(Pixel_1_to_buffer[7]),
        .iPixel_1_PE_8(Pixel_1_to_buffer[8]),
        .iPixel_1_PE_9(Pixel_1_to_buffer[9]),                          
    
        .iPixel_0_PE_0_valid(Pixel_0_to_buffer_valid[0]),
        .iPixel_0_PE_1_valid(Pixel_0_to_buffer_valid[1]),
        .iPixel_0_PE_2_valid(Pixel_0_to_buffer_valid[2]),
        .iPixel_0_PE_3_valid(Pixel_0_to_buffer_valid[3]),
        .iPixel_0_PE_4_valid(Pixel_0_to_buffer_valid[4]),
        .iPixel_0_PE_5_valid(Pixel_0_to_buffer_valid[5]),
        .iPixel_0_PE_6_valid(Pixel_0_to_buffer_valid[6]),
        .iPixel_0_PE_7_valid(Pixel_0_to_buffer_valid[7]),
        .iPixel_0_PE_8_valid(Pixel_0_to_buffer_valid[8]),
        .iPixel_0_PE_9_valid(Pixel_0_to_buffer_valid[9]),     
        
        .iPixel_1_PE_0_valid(Pixel_1_to_buffer_valid[0]),
        .iPixel_1_PE_1_valid(Pixel_1_to_buffer_valid[1]),
        .iPixel_1_PE_2_valid(Pixel_1_to_buffer_valid[2]),
        .iPixel_1_PE_3_valid(Pixel_1_to_buffer_valid[3]),
        .iPixel_1_PE_4_valid(Pixel_1_to_buffer_valid[4]),
        .iPixel_1_PE_5_valid(Pixel_1_to_buffer_valid[5]),
        .iPixel_1_PE_6_valid(Pixel_1_to_buffer_valid[6]),
        .iPixel_1_PE_7_valid(Pixel_1_to_buffer_valid[7]),
        .iPixel_1_PE_8_valid(Pixel_1_to_buffer_valid[8]),
        .iPixel_1_PE_9_valid(Pixel_1_to_buffer_valid[9]),  
        
        .oPixel_0_PE_0(Pixel_0_to_PE[0]),
        .oPixel_0_PE_1(Pixel_0_to_PE[1]),
        .oPixel_0_PE_2(Pixel_0_to_PE[2]),
        .oPixel_0_PE_3(Pixel_0_to_PE[3]),
        .oPixel_0_PE_4(Pixel_0_to_PE[4]),
        .oPixel_0_PE_5(Pixel_0_to_PE[5]),
        .oPixel_0_PE_6(Pixel_0_to_PE[6]),
        .oPixel_0_PE_7(Pixel_0_to_PE[7]),
        .oPixel_0_PE_8(Pixel_0_to_PE[8]),
        .oPixel_0_PE_9(Pixel_0_to_PE[9]),    
        
        .oPixel_1_PE_0(Pixel_1_to_PE[0]),
        .oPixel_1_PE_1(Pixel_1_to_PE[1]),
        .oPixel_1_PE_2(Pixel_1_to_PE[2]),
        .oPixel_1_PE_3(Pixel_1_to_PE[3]),
        .oPixel_1_PE_4(Pixel_1_to_PE[4]),
        .oPixel_1_PE_5(Pixel_1_to_PE[5]),
        .oPixel_1_PE_6(Pixel_1_to_PE[6]),
        .oPixel_1_PE_7(Pixel_1_to_PE[7]),
        .oPixel_1_PE_8(Pixel_1_to_PE[8]),
        .oPixel_1_PE_9(Pixel_1_to_PE[9]),    
        
        .oPixel_2_PE_0(Pixel_2_to_PE[0]),
        .oPixel_2_PE_1(Pixel_2_to_PE[1]),
        .oPixel_2_PE_2(Pixel_2_to_PE[2]),
        .oPixel_2_PE_3(Pixel_2_to_PE[3]),
        .oPixel_2_PE_4(Pixel_2_to_PE[4]),
        .oPixel_2_PE_5(Pixel_2_to_PE[5]),
        .oPixel_2_PE_6(Pixel_2_to_PE[6]),
        .oPixel_2_PE_7(Pixel_2_to_PE[7]),
        .oPixel_2_PE_8(Pixel_2_to_PE[8]),
        .oPixel_2_PE_9(Pixel_2_to_PE[9]),
    
        .oPixel_0_PE_0_valid(Pixel_0_to_PE_valid[0]),
        .oPixel_0_PE_1_valid(Pixel_0_to_PE_valid[1]),
        .oPixel_0_PE_2_valid(Pixel_0_to_PE_valid[2]),
        .oPixel_0_PE_3_valid(Pixel_0_to_PE_valid[3]),
        .oPixel_0_PE_4_valid(Pixel_0_to_PE_valid[4]),
        .oPixel_0_PE_5_valid(Pixel_0_to_PE_valid[5]),
        .oPixel_0_PE_6_valid(Pixel_0_to_PE_valid[6]),
        .oPixel_0_PE_7_valid(Pixel_0_to_PE_valid[7]),
        .oPixel_0_PE_8_valid(Pixel_0_to_PE_valid[8]),
        .oPixel_0_PE_9_valid(Pixel_0_to_PE_valid[9]),
        
        .oPixel_1_PE_0_valid(Pixel_1_to_PE_valid[0]),
        .oPixel_1_PE_1_valid(Pixel_1_to_PE_valid[1]),
        .oPixel_1_PE_2_valid(Pixel_1_to_PE_valid[2]),
        .oPixel_1_PE_3_valid(Pixel_1_to_PE_valid[3]),
        .oPixel_1_PE_4_valid(Pixel_1_to_PE_valid[4]),
        .oPixel_1_PE_5_valid(Pixel_1_to_PE_valid[5]),
        .oPixel_1_PE_6_valid(Pixel_1_to_PE_valid[6]),
        .oPixel_1_PE_7_valid(Pixel_1_to_PE_valid[7]),
        .oPixel_1_PE_8_valid(Pixel_1_to_PE_valid[8]),
        .oPixel_1_PE_9_valid(Pixel_1_to_PE_valid[9]),    
        
        .oPixel_2_PE_0_valid(Pixel_2_to_PE_valid[0]),
        .oPixel_2_PE_1_valid(Pixel_2_to_PE_valid[1]),
        .oPixel_2_PE_2_valid(Pixel_2_to_PE_valid[2]),
        .oPixel_2_PE_3_valid(Pixel_2_to_PE_valid[3]),
        .oPixel_2_PE_4_valid(Pixel_2_to_PE_valid[4]),
        .oPixel_2_PE_5_valid(Pixel_2_to_PE_valid[5]),
        .oPixel_2_PE_6_valid(Pixel_2_to_PE_valid[6]),
        .oPixel_2_PE_7_valid(Pixel_2_to_PE_valid[7]),
        .oPixel_2_PE_8_valid(Pixel_2_to_PE_valid[8]),
        .oPixel_2_PE_9_valid(Pixel_2_to_PE_valid[9])
    );
endmodule
