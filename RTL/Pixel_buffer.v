`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2026 10:33:53 AM
// Design Name: 
// Module Name: Pixel_buffer
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

module pixel_buffer
#(parameter DATA_WIDTH = 8)
( 
    input iClk,
    input iRst,
    input [1:0]iCfg,
    input iStride, // 0 for 1, 1 for 2
    input [3:0]iMUX_Sel,
    input iMP_FP,
    input iMP_LP,
    input iMP_LP_First,
    
    input [DATA_WIDTH-1:0]iPixel_0_PE_0,
    input [DATA_WIDTH-1:0]iPixel_0_PE_1,
    input [DATA_WIDTH-1:0]iPixel_0_PE_2,
    input [DATA_WIDTH-1:0]iPixel_0_PE_3,
    input [DATA_WIDTH-1:0]iPixel_0_PE_4,
    input [DATA_WIDTH-1:0]iPixel_0_PE_5,
    input [DATA_WIDTH-1:0]iPixel_0_PE_6,
    input [DATA_WIDTH-1:0]iPixel_0_PE_7,
    input [DATA_WIDTH-1:0]iPixel_0_PE_8,
    input [DATA_WIDTH-1:0]iPixel_0_PE_9,
                         
    
    input [DATA_WIDTH-1:0]iPixel_1_PE_0,
    input [DATA_WIDTH-1:0]iPixel_1_PE_1,
    input [DATA_WIDTH-1:0]iPixel_1_PE_2,
    input [DATA_WIDTH-1:0]iPixel_1_PE_3,
    input [DATA_WIDTH-1:0]iPixel_1_PE_4,
    input [DATA_WIDTH-1:0]iPixel_1_PE_5,
    input [DATA_WIDTH-1:0]iPixel_1_PE_6,
    input [DATA_WIDTH-1:0]iPixel_1_PE_7,
    input [DATA_WIDTH-1:0]iPixel_1_PE_8,
    input [DATA_WIDTH-1:0]iPixel_1_PE_9,                        

    input iPixel_0_PE_0_valid,
    input iPixel_0_PE_1_valid,
    input iPixel_0_PE_2_valid,
    input iPixel_0_PE_3_valid,
    input iPixel_0_PE_4_valid,
    input iPixel_0_PE_5_valid,
    input iPixel_0_PE_6_valid,
    input iPixel_0_PE_7_valid,
    input iPixel_0_PE_8_valid,
    input iPixel_0_PE_9_valid,    
    
    input iPixel_1_PE_0_valid,
    input iPixel_1_PE_1_valid,
    input iPixel_1_PE_2_valid,
    input iPixel_1_PE_3_valid,
    input iPixel_1_PE_4_valid,
    input iPixel_1_PE_5_valid,
    input iPixel_1_PE_6_valid,
    input iPixel_1_PE_7_valid,
    input iPixel_1_PE_8_valid,
    input iPixel_1_PE_9_valid,    
    
    output [DATA_WIDTH-1:0]oPixel_0_PE_0,
    output [DATA_WIDTH-1:0]oPixel_0_PE_1,
    output [DATA_WIDTH-1:0]oPixel_0_PE_2,
    output [DATA_WIDTH-1:0]oPixel_0_PE_3,
    output [DATA_WIDTH-1:0]oPixel_0_PE_4,
    output [DATA_WIDTH-1:0]oPixel_0_PE_5,
    output [DATA_WIDTH-1:0]oPixel_0_PE_6,
    output [DATA_WIDTH-1:0]oPixel_0_PE_7,
    output [DATA_WIDTH-1:0]oPixel_0_PE_8,
    output [DATA_WIDTH-1:0]oPixel_0_PE_9,    
    
    output [DATA_WIDTH-1:0]oPixel_1_PE_0,
    output [DATA_WIDTH-1:0]oPixel_1_PE_1,
    output [DATA_WIDTH-1:0]oPixel_1_PE_2,
    output [DATA_WIDTH-1:0]oPixel_1_PE_3,
    output [DATA_WIDTH-1:0]oPixel_1_PE_4,
    output [DATA_WIDTH-1:0]oPixel_1_PE_5,
    output [DATA_WIDTH-1:0]oPixel_1_PE_6,
    output [DATA_WIDTH-1:0]oPixel_1_PE_7,
    output [DATA_WIDTH-1:0]oPixel_1_PE_8,
    output [DATA_WIDTH-1:0]oPixel_1_PE_9,    
    
    output [DATA_WIDTH-1:0]oPixel_2_PE_0,
    output [DATA_WIDTH-1:0]oPixel_2_PE_1,
    output [DATA_WIDTH-1:0]oPixel_2_PE_2,
    output [DATA_WIDTH-1:0]oPixel_2_PE_3,
    output [DATA_WIDTH-1:0]oPixel_2_PE_4,
    output [DATA_WIDTH-1:0]oPixel_2_PE_5,
    output [DATA_WIDTH-1:0]oPixel_2_PE_6,
    output [DATA_WIDTH-1:0]oPixel_2_PE_7,
    output [DATA_WIDTH-1:0]oPixel_2_PE_8,
    output [DATA_WIDTH-1:0]oPixel_2_PE_9,

    output oPixel_0_PE_0_valid,
    output oPixel_0_PE_1_valid,
    output oPixel_0_PE_2_valid,
    output oPixel_0_PE_3_valid,
    output oPixel_0_PE_4_valid,
    output oPixel_0_PE_5_valid,
    output oPixel_0_PE_6_valid,
    output oPixel_0_PE_7_valid,
    output oPixel_0_PE_8_valid,
    output oPixel_0_PE_9_valid,    
    
    output oPixel_1_PE_0_valid,
    output oPixel_1_PE_1_valid,
    output oPixel_1_PE_2_valid,
    output oPixel_1_PE_3_valid,
    output oPixel_1_PE_4_valid,
    output oPixel_1_PE_5_valid,
    output oPixel_1_PE_6_valid,
    output oPixel_1_PE_7_valid,
    output oPixel_1_PE_8_valid,
    output oPixel_1_PE_9_valid,    
    
    output oPixel_2_PE_0_valid,
    output oPixel_2_PE_1_valid,
    output oPixel_2_PE_2_valid,
    output oPixel_2_PE_3_valid,
    output oPixel_2_PE_4_valid,
    output oPixel_2_PE_5_valid,
    output oPixel_2_PE_6_valid,
    output oPixel_2_PE_7_valid,
    output oPixel_2_PE_8_valid,
    output oPixel_2_PE_9_valid
    );
    
    localparam MAC = 2'b00;
    localparam MAX = 2'b01;
    localparam GAP = 2'b10;
    
    wire [DATA_WIDTH-1:0] PE_0_to_MUX;
    wire [DATA_WIDTH-1:0] PE_1_to_MUX;
    wire [DATA_WIDTH-1:0] PE_2_to_MUX;
    wire [DATA_WIDTH-1:0] PE_3_to_MUX;
    wire [DATA_WIDTH-1:0] PE_4_to_MUX;
    wire [DATA_WIDTH-1:0] PE_5_to_MUX;
    wire [DATA_WIDTH-1:0] PE_6_to_MUX;
    wire [DATA_WIDTH-1:0] PE_7_to_MUX;
    wire [DATA_WIDTH-1:0] PE_8_to_MUX;
    wire [DATA_WIDTH-1:0] PE_9_to_MUX;

    wire [DATA_WIDTH-1:0] Pixel_0_PE_0_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_1_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_2_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_3_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_4_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_5_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_6_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_7_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_8_wire;
    wire [DATA_WIDTH-1:0] Pixel_0_PE_9_wire;

    wire [DATA_WIDTH-1:0] Pixel_1_PE_0_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_1_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_2_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_3_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_4_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_5_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_6_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_7_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_8_wire;
    wire [DATA_WIDTH-1:0] Pixel_1_PE_9_wire;

    wire [DATA_WIDTH-1:0] Pixel_2_PE_0_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_1_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_2_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_3_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_4_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_5_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_6_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_7_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_8_wire;
    wire [DATA_WIDTH-1:0] Pixel_2_PE_9_wire;

    reg Pixel_0_PE_0_valid_reg;
    reg Pixel_0_PE_1_valid_reg;
    reg Pixel_0_PE_2_valid_reg;
    reg Pixel_0_PE_3_valid_reg;
    reg Pixel_0_PE_4_valid_reg;
    reg Pixel_0_PE_5_valid_reg;
    reg Pixel_0_PE_6_valid_reg;
    reg Pixel_0_PE_7_valid_reg;
    reg Pixel_0_PE_8_valid_reg;
    reg Pixel_0_PE_9_valid_reg;    
    
    reg Pixel_1_PE_0_valid_reg;
    reg Pixel_1_PE_1_valid_reg;
    reg Pixel_1_PE_2_valid_reg;
    reg Pixel_1_PE_3_valid_reg;
    reg Pixel_1_PE_4_valid_reg;
    reg Pixel_1_PE_5_valid_reg;
    reg Pixel_1_PE_6_valid_reg;
    reg Pixel_1_PE_7_valid_reg;
    reg Pixel_1_PE_8_valid_reg;
    reg Pixel_1_PE_9_valid_reg;    
    
    reg Pixel_2_PE_0_valid_reg;
    reg Pixel_2_PE_1_valid_reg;
    reg Pixel_2_PE_2_valid_reg;
    reg Pixel_2_PE_3_valid_reg;
    reg Pixel_2_PE_4_valid_reg;
    reg Pixel_2_PE_5_valid_reg;
    reg Pixel_2_PE_6_valid_reg;
    reg Pixel_2_PE_7_valid_reg;
    reg Pixel_2_PE_8_valid_reg;
    reg Pixel_2_PE_9_valid_reg;

    reg [DATA_WIDTH-1:0] Pixel_0_PE_0_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_1_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_2_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_3_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_4_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_5_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_6_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_7_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_8_reg;
    reg [DATA_WIDTH-1:0] Pixel_0_PE_9_reg;

    reg [DATA_WIDTH-1:0] Pixel_1_PE_0_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_1_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_2_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_3_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_4_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_5_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_6_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_7_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_8_reg;
    reg [DATA_WIDTH-1:0] Pixel_1_PE_9_reg;

    reg [DATA_WIDTH-1:0] Pixel_2_PE_0_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_1_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_2_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_3_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_4_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_5_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_6_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_7_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_8_reg;
    reg [DATA_WIDTH-1:0] Pixel_2_PE_9_reg;

    assign PE_0_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_0 : iPixel_0_PE_0;
    assign PE_1_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_2 : iPixel_0_PE_1;
    assign PE_2_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_4 : iPixel_0_PE_2;
    assign PE_3_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_6 : iPixel_0_PE_3;
    assign PE_4_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_8 : iPixel_0_PE_4;
    assign PE_5_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_0 : iPixel_0_PE_5;
    assign PE_6_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_2 : iPixel_0_PE_6;
    assign PE_7_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_4 : iPixel_0_PE_7;
    assign PE_8_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_6 : iPixel_0_PE_8;
    assign PE_9_to_MUX = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_8 : (iMP_LP) ? -128 : iPixel_0_PE_9;

    MUX10_1 MUX_0_PE_0 (
        .data0_in(PE_0_to_MUX),
        .data1_in(PE_1_to_MUX),
        .data2_in(PE_2_to_MUX),
        .data3_in(PE_3_to_MUX),
        .data4_in(PE_4_to_MUX),
        .data5_in(PE_5_to_MUX),
        .data6_in(PE_6_to_MUX),
        .data7_in(PE_7_to_MUX),
        .data8_in(PE_8_to_MUX),
        .data9_in(PE_9_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_0_wire)
    );

    MUX10_1 MUX_0_PE_1 (
        .data0_in(PE_1_to_MUX),
        .data1_in(PE_2_to_MUX),
        .data2_in(PE_3_to_MUX),
        .data3_in(PE_4_to_MUX),
        .data4_in(PE_5_to_MUX),
        .data5_in(PE_6_to_MUX),
        .data6_in(PE_7_to_MUX),
        .data7_in(PE_8_to_MUX),
        .data8_in(PE_9_to_MUX),
        .data9_in(PE_0_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_1_wire)
    );

    MUX10_1 MUX_0_PE_2 (
        .data0_in(PE_2_to_MUX),
        .data1_in(PE_3_to_MUX),
        .data2_in(PE_4_to_MUX),
        .data3_in(PE_5_to_MUX),
        .data4_in(PE_6_to_MUX),
        .data5_in(PE_7_to_MUX),
        .data6_in(PE_8_to_MUX),
        .data7_in(PE_9_to_MUX),
        .data8_in(PE_0_to_MUX),
        .data9_in(PE_1_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_2_wire)
    );

    MUX10_1 MUX_0_PE_3 (
        .data0_in(PE_3_to_MUX),
        .data1_in(PE_4_to_MUX),
        .data2_in(PE_5_to_MUX),
        .data3_in(PE_6_to_MUX),
        .data4_in(PE_7_to_MUX),
        .data5_in(PE_8_to_MUX),
        .data6_in(PE_9_to_MUX),
        .data7_in(PE_0_to_MUX),
        .data8_in(PE_1_to_MUX),
        .data9_in(PE_2_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_3_wire)
    );

    MUX10_1 MUX_0_PE_4 (
        .data0_in(PE_4_to_MUX),
        .data1_in(PE_5_to_MUX),
        .data2_in(PE_6_to_MUX),
        .data3_in(PE_7_to_MUX),
        .data4_in(PE_8_to_MUX),
        .data5_in(PE_9_to_MUX),
        .data6_in(PE_0_to_MUX),
        .data7_in(PE_1_to_MUX),
        .data8_in(PE_2_to_MUX),
        .data9_in(PE_3_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_4_wire)
    );

    MUX10_1 MUX_0_PE_5 (
        .data0_in(PE_5_to_MUX),
        .data1_in(PE_6_to_MUX),
        .data2_in(PE_7_to_MUX),
        .data3_in(PE_8_to_MUX),
        .data4_in(PE_9_to_MUX),
        .data5_in(PE_0_to_MUX),
        .data6_in(PE_1_to_MUX),
        .data7_in(PE_2_to_MUX),
        .data8_in(PE_3_to_MUX),
        .data9_in(PE_4_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_5_wire)
    );
    MUX10_1 MUX_0_PE_6 (
        .data0_in(PE_6_to_MUX),
        .data1_in(PE_7_to_MUX),
        .data2_in(PE_8_to_MUX),
        .data3_in(PE_9_to_MUX),
        .data4_in(PE_0_to_MUX),
        .data5_in(PE_1_to_MUX),
        .data6_in(PE_2_to_MUX),
        .data7_in(PE_3_to_MUX),
        .data8_in(PE_4_to_MUX),
        .data9_in(PE_5_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_6_wire)
    );
    MUX10_1 MUX_0_PE_7 (
        .data0_in(PE_7_to_MUX),
        .data1_in(PE_8_to_MUX),
        .data2_in(PE_9_to_MUX),
        .data3_in(PE_0_to_MUX),
        .data4_in(PE_1_to_MUX),
        .data5_in(PE_2_to_MUX),
        .data6_in(PE_3_to_MUX),
        .data7_in(PE_4_to_MUX),
        .data8_in(PE_5_to_MUX),
        .data9_in(PE_6_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_7_wire)
    );

    MUX10_1 MUX_0_PE_8 (
        .data0_in(PE_8_to_MUX),
        .data1_in(PE_9_to_MUX),
        .data2_in(PE_0_to_MUX),
        .data3_in(PE_1_to_MUX),
        .data4_in(PE_2_to_MUX),
        .data5_in(PE_3_to_MUX),
        .data6_in(PE_4_to_MUX),
        .data7_in(PE_5_to_MUX),
        .data8_in(PE_6_to_MUX),
        .data9_in(PE_7_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_8_wire)
    );
    MUX10_1 MUX_0_PE_9 (
        .data0_in(PE_9_to_MUX),
        .data1_in(PE_0_to_MUX),
        .data2_in(PE_1_to_MUX),
        .data3_in(PE_2_to_MUX),
        .data4_in(PE_3_to_MUX),
        .data5_in(PE_4_to_MUX),
        .data6_in(PE_5_to_MUX),
        .data7_in(PE_6_to_MUX),
        .data8_in(PE_7_to_MUX),
        .data9_in(PE_8_to_MUX),
        .sel_in(iMUX_Sel),
        .mux_10_1_out(Pixel_0_PE_9_wire)
    );

    assign Pixel_1_PE_0_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_1 : iPixel_0_PE_0;
    assign Pixel_1_PE_1_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_3 : iPixel_0_PE_1;
    assign Pixel_1_PE_2_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_5 : iPixel_0_PE_2;
    assign Pixel_1_PE_3_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_7 : iPixel_0_PE_3;
    assign Pixel_1_PE_4_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_9 : iPixel_0_PE_4;
    assign Pixel_1_PE_5_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_1 : iPixel_0_PE_5;
    assign Pixel_1_PE_6_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_3 : iPixel_0_PE_6;
    assign Pixel_1_PE_7_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_5 : iPixel_0_PE_7;
    assign Pixel_1_PE_8_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_7 : iPixel_0_PE_8;
    assign Pixel_1_PE_9_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_9 : (iMP_LP_First) ? iPixel_0_PE_9 : iPixel_1_PE_9;

    assign Pixel_2_PE_0_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_1 : iPixel_0_PE_1;
    assign Pixel_2_PE_1_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_3 : iPixel_0_PE_2;
    assign Pixel_2_PE_2_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_5 : iPixel_0_PE_3;
    assign Pixel_2_PE_3_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_7 : iPixel_0_PE_4;
    assign Pixel_2_PE_4_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_0_PE_9 : iPixel_0_PE_5;
    assign Pixel_2_PE_5_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_1 : iPixel_0_PE_6;
    assign Pixel_2_PE_6_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_3 : iPixel_0_PE_7;
    assign Pixel_2_PE_7_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_5 : iPixel_0_PE_8;
    assign Pixel_2_PE_8_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_7 : (iMP_LP_First) ? iPixel_0_PE_9 : iPixel_1_PE_9;
    assign Pixel_2_PE_9_wire = (iCfg == MAX) && (iStride == 1'b1) ? iPixel_1_PE_9 : (iMP_FP) ? -128 :  iPixel_1_PE_0;
    
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            Pixel_0_PE_0_reg <= 0;
            Pixel_0_PE_1_reg <= 0;
            Pixel_0_PE_2_reg <= 0;
            Pixel_0_PE_3_reg <= 0;
            Pixel_0_PE_4_reg <= 0;
            Pixel_0_PE_5_reg <= 0;
            Pixel_0_PE_6_reg <= 0;
            Pixel_0_PE_7_reg <= 0;
            Pixel_0_PE_8_reg <= 0;
            Pixel_0_PE_9_reg <= 0;

            Pixel_1_PE_0_reg <= 0;
            Pixel_1_PE_1_reg <= 0;
            Pixel_1_PE_2_reg <= 0;
            Pixel_1_PE_3_reg <= 0;
            Pixel_1_PE_4_reg <= 0;
            Pixel_1_PE_5_reg <= 0;
            Pixel_1_PE_6_reg <= 0;
            Pixel_1_PE_7_reg <= 0;
            Pixel_1_PE_8_reg <= 0;
            Pixel_1_PE_9_reg <= 0;

            Pixel_2_PE_0_reg <= 0;
            Pixel_2_PE_1_reg <= 0;
            Pixel_2_PE_2_reg <= 0;
            Pixel_2_PE_3_reg <= 0;
            Pixel_2_PE_4_reg <= 0;
            Pixel_2_PE_5_reg <= 0;
            Pixel_2_PE_6_reg <= 0;
            Pixel_2_PE_7_reg <= 0;
            Pixel_2_PE_8_reg <= 0;
            Pixel_2_PE_9_reg <= 0;
            
            Pixel_0_PE_0_valid_reg <= 1'b0;
            Pixel_0_PE_1_valid_reg <= 1'b0;
            Pixel_0_PE_2_valid_reg <= 1'b0;
            Pixel_0_PE_3_valid_reg <= 1'b0;
            Pixel_0_PE_4_valid_reg <= 1'b0;
            Pixel_0_PE_5_valid_reg <= 1'b0;
            Pixel_0_PE_6_valid_reg <= 1'b0;
            Pixel_0_PE_7_valid_reg <= 1'b0;
            Pixel_0_PE_8_valid_reg <= 1'b0;
            Pixel_0_PE_9_valid_reg <= 1'b0;

            Pixel_1_PE_0_valid_reg <= 1'b0;
            Pixel_1_PE_1_valid_reg <= 1'b0;
            Pixel_1_PE_2_valid_reg <= 1'b0;
            Pixel_1_PE_3_valid_reg <= 1'b0;
            Pixel_1_PE_4_valid_reg <= 1'b0;
            Pixel_1_PE_5_valid_reg <= 1'b0;
            Pixel_1_PE_6_valid_reg <= 1'b0;
            Pixel_1_PE_7_valid_reg <= 1'b0;
            Pixel_1_PE_8_valid_reg <= 1'b0;
            Pixel_1_PE_9_valid_reg <= 1'b0;

            Pixel_2_PE_0_valid_reg <= 1'b0;
            Pixel_2_PE_1_valid_reg <= 1'b0;
            Pixel_2_PE_2_valid_reg <= 1'b0;
            Pixel_2_PE_3_valid_reg <= 1'b0;
            Pixel_2_PE_4_valid_reg <= 1'b0;
            Pixel_2_PE_5_valid_reg <= 1'b0;
            Pixel_2_PE_6_valid_reg <= 1'b0;
            Pixel_2_PE_7_valid_reg <= 1'b0;
            Pixel_2_PE_8_valid_reg <= 1'b0;
            Pixel_2_PE_9_valid_reg <= 1'b0;

        end
        else begin
            Pixel_0_PE_0_reg <= Pixel_0_PE_0_wire;
            Pixel_0_PE_1_reg <= Pixel_0_PE_1_wire;
            Pixel_0_PE_2_reg <= Pixel_0_PE_2_wire;
            Pixel_0_PE_3_reg <= Pixel_0_PE_3_wire;
            Pixel_0_PE_4_reg <= Pixel_0_PE_4_wire;
            Pixel_0_PE_5_reg <= Pixel_0_PE_5_wire;
            Pixel_0_PE_6_reg <= Pixel_0_PE_6_wire;
            Pixel_0_PE_7_reg <= Pixel_0_PE_7_wire;
            Pixel_0_PE_8_reg <= Pixel_0_PE_8_wire;
            Pixel_0_PE_9_reg <= Pixel_0_PE_9_wire;

            Pixel_1_PE_0_reg <= Pixel_1_PE_0_wire;
            Pixel_1_PE_1_reg <= Pixel_1_PE_1_wire;
            Pixel_1_PE_2_reg <= Pixel_1_PE_2_wire;
            Pixel_1_PE_3_reg <= Pixel_1_PE_3_wire;
            Pixel_1_PE_4_reg <= Pixel_1_PE_4_wire;
            Pixel_1_PE_5_reg <= Pixel_1_PE_5_wire;
            Pixel_1_PE_6_reg <= Pixel_1_PE_6_wire;
            Pixel_1_PE_7_reg <= Pixel_1_PE_7_wire;
            Pixel_1_PE_8_reg <= Pixel_1_PE_8_wire;
            Pixel_1_PE_9_reg <= Pixel_1_PE_9_wire;

            Pixel_2_PE_0_reg <= Pixel_2_PE_0_wire;
            Pixel_2_PE_1_reg <= Pixel_2_PE_1_wire;
            Pixel_2_PE_2_reg <= Pixel_2_PE_2_wire;
            Pixel_2_PE_3_reg <= Pixel_2_PE_3_wire;
            Pixel_2_PE_4_reg <= Pixel_2_PE_4_wire;
            Pixel_2_PE_5_reg <= Pixel_2_PE_5_wire;
            Pixel_2_PE_6_reg <= Pixel_2_PE_6_wire;
            Pixel_2_PE_7_reg <= Pixel_2_PE_7_wire;
            Pixel_2_PE_8_reg <= Pixel_2_PE_8_wire;
            Pixel_2_PE_9_reg <= Pixel_2_PE_9_wire;

            Pixel_0_PE_0_valid_reg <= iPixel_0_PE_0_valid;
            Pixel_0_PE_1_valid_reg <= iPixel_0_PE_1_valid;
            Pixel_0_PE_2_valid_reg <= iPixel_0_PE_2_valid;
            Pixel_0_PE_3_valid_reg <= iPixel_0_PE_3_valid;
            Pixel_0_PE_4_valid_reg <= iPixel_0_PE_4_valid;
            Pixel_0_PE_5_valid_reg <= iPixel_0_PE_5_valid;
            Pixel_0_PE_6_valid_reg <= iPixel_0_PE_6_valid;
            Pixel_0_PE_7_valid_reg <= iPixel_0_PE_7_valid;
            Pixel_0_PE_8_valid_reg <= iPixel_0_PE_8_valid;
            Pixel_0_PE_9_valid_reg <= iPixel_0_PE_9_valid;

            Pixel_1_PE_0_valid_reg <= iPixel_1_PE_0_valid;
            Pixel_1_PE_1_valid_reg <= iPixel_1_PE_1_valid;
            Pixel_1_PE_2_valid_reg <= iPixel_1_PE_2_valid;
            Pixel_1_PE_3_valid_reg <= iPixel_1_PE_3_valid;
            Pixel_1_PE_4_valid_reg <= iPixel_1_PE_4_valid;
            Pixel_1_PE_5_valid_reg <= iPixel_1_PE_5_valid;
            Pixel_1_PE_6_valid_reg <= iPixel_1_PE_6_valid;
            Pixel_1_PE_7_valid_reg <= iPixel_1_PE_7_valid;
            Pixel_1_PE_8_valid_reg <= iPixel_1_PE_8_valid;
            Pixel_1_PE_9_valid_reg <= iPixel_1_PE_9_valid;

            Pixel_2_PE_0_valid_reg <= iPixel_1_PE_0_valid;
            Pixel_2_PE_1_valid_reg <= iPixel_1_PE_1_valid;
            Pixel_2_PE_2_valid_reg <= iPixel_1_PE_2_valid;
            Pixel_2_PE_3_valid_reg <= iPixel_1_PE_3_valid;
            Pixel_2_PE_4_valid_reg <= iPixel_1_PE_4_valid;
            Pixel_2_PE_5_valid_reg <= iPixel_1_PE_5_valid;
            Pixel_2_PE_6_valid_reg <= iPixel_1_PE_6_valid;
            Pixel_2_PE_7_valid_reg <= iPixel_1_PE_7_valid;
            Pixel_2_PE_8_valid_reg <= iPixel_1_PE_8_valid;
            Pixel_2_PE_9_valid_reg <= iPixel_1_PE_9_valid;
        end
    end

    assign oPixel_0_PE_0 = Pixel_0_PE_0_reg;
    assign oPixel_0_PE_1 = Pixel_0_PE_1_reg;
    assign oPixel_0_PE_2 = Pixel_0_PE_2_reg;
    assign oPixel_0_PE_3 = Pixel_0_PE_3_reg;
    assign oPixel_0_PE_4 = Pixel_0_PE_4_reg;
    assign oPixel_0_PE_5 = Pixel_0_PE_5_reg;
    assign oPixel_0_PE_6 = Pixel_0_PE_6_reg;
    assign oPixel_0_PE_7 = Pixel_0_PE_7_reg;
    assign oPixel_0_PE_8 = Pixel_0_PE_8_reg;
    assign oPixel_0_PE_9 = Pixel_0_PE_9_reg;

    assign oPixel_1_PE_0 = Pixel_1_PE_0_reg;
    assign oPixel_1_PE_1 = Pixel_1_PE_1_reg;
    assign oPixel_1_PE_2 = Pixel_1_PE_2_reg;
    assign oPixel_1_PE_3 = Pixel_1_PE_3_reg;
    assign oPixel_1_PE_4 = Pixel_1_PE_4_reg;
    assign oPixel_1_PE_5 = Pixel_1_PE_5_reg;
    assign oPixel_1_PE_6 = Pixel_1_PE_6_reg;
    assign oPixel_1_PE_7 = Pixel_1_PE_7_reg;
    assign oPixel_1_PE_8 = Pixel_1_PE_8_reg;
    assign oPixel_1_PE_9 = Pixel_1_PE_9_reg;

    assign oPixel_2_PE_0 = Pixel_2_PE_0_reg;
    assign oPixel_2_PE_1 = Pixel_2_PE_1_reg;
    assign oPixel_2_PE_2 = Pixel_2_PE_2_reg;
    assign oPixel_2_PE_3 = Pixel_2_PE_3_reg;
    assign oPixel_2_PE_4 = Pixel_2_PE_4_reg;
    assign oPixel_2_PE_5 = Pixel_2_PE_5_reg;
    assign oPixel_2_PE_6 = Pixel_2_PE_6_reg;
    assign oPixel_2_PE_7 = Pixel_2_PE_7_reg;
    assign oPixel_2_PE_8 = Pixel_2_PE_8_reg;
    assign oPixel_2_PE_9 = Pixel_2_PE_9_reg;

    assign oPixel_0_PE_0_valid = Pixel_0_PE_0_valid_reg;
    assign oPixel_0_PE_1_valid = Pixel_0_PE_1_valid_reg;
    assign oPixel_0_PE_2_valid = Pixel_0_PE_2_valid_reg;
    assign oPixel_0_PE_3_valid = Pixel_0_PE_3_valid_reg;
    assign oPixel_0_PE_4_valid = Pixel_0_PE_4_valid_reg;
    assign oPixel_0_PE_5_valid = Pixel_0_PE_5_valid_reg;
    assign oPixel_0_PE_6_valid = Pixel_0_PE_6_valid_reg;
    assign oPixel_0_PE_7_valid = Pixel_0_PE_7_valid_reg;
    assign oPixel_0_PE_8_valid = Pixel_0_PE_8_valid_reg;
    assign oPixel_0_PE_9_valid = Pixel_0_PE_9_valid_reg;

    assign oPixel_1_PE_0_valid = Pixel_1_PE_0_valid_reg;
    assign oPixel_1_PE_1_valid = Pixel_1_PE_1_valid_reg;
    assign oPixel_1_PE_2_valid = Pixel_1_PE_2_valid_reg;
    assign oPixel_1_PE_3_valid = Pixel_1_PE_3_valid_reg;
    assign oPixel_1_PE_4_valid = Pixel_1_PE_4_valid_reg;
    assign oPixel_1_PE_5_valid = Pixel_1_PE_5_valid_reg;
    assign oPixel_1_PE_6_valid = Pixel_1_PE_6_valid_reg;
    assign oPixel_1_PE_7_valid = Pixel_1_PE_7_valid_reg;
    assign oPixel_1_PE_8_valid = Pixel_1_PE_8_valid_reg;
    assign oPixel_1_PE_9_valid = Pixel_1_PE_9_valid_reg;

    assign oPixel_2_PE_0_valid = Pixel_2_PE_0_valid_reg;
    assign oPixel_2_PE_1_valid = Pixel_2_PE_1_valid_reg;
    assign oPixel_2_PE_2_valid = Pixel_2_PE_2_valid_reg;
    assign oPixel_2_PE_3_valid = Pixel_2_PE_3_valid_reg;
    assign oPixel_2_PE_4_valid = Pixel_2_PE_4_valid_reg;
    assign oPixel_2_PE_5_valid = Pixel_2_PE_5_valid_reg;
    assign oPixel_2_PE_6_valid = Pixel_2_PE_6_valid_reg;
    assign oPixel_2_PE_7_valid = Pixel_2_PE_7_valid_reg;
    assign oPixel_2_PE_8_valid = Pixel_2_PE_8_valid_reg;
    assign oPixel_2_PE_9_valid = Pixel_2_PE_9_valid_reg;
 
endmodule

module MUX10_1 
#(parameter DATA_WIDTH = 8)
(
    input [DATA_WIDTH-1:0] data0_in,
    input [DATA_WIDTH-1:0] data1_in,
    input [DATA_WIDTH-1:0] data2_in,
    input [DATA_WIDTH-1:0] data3_in,
    input [DATA_WIDTH-1:0] data4_in,
    input [DATA_WIDTH-1:0] data5_in,
    input [DATA_WIDTH-1:0] data6_in,
    input [DATA_WIDTH-1:0] data7_in,
    input [DATA_WIDTH-1:0] data8_in,
    input [DATA_WIDTH-1:0] data9_in,
    input [3:0] sel_in,
    output reg [DATA_WIDTH-1:0] mux_10_1_out
);

    always @*
    case(sel_in)
        4'd0: mux_10_1_out = data0_in;
        4'd1: mux_10_1_out = data1_in;
        4'd2: mux_10_1_out = data2_in;
        4'd3: mux_10_1_out = data3_in;
        4'd4: mux_10_1_out = data4_in;
        4'd5: mux_10_1_out = data5_in;
        4'd6: mux_10_1_out = data6_in;
        4'd7: mux_10_1_out = data7_in;
        4'd8: mux_10_1_out = data8_in;
        4'd9: mux_10_1_out = data9_in;
        default: mux_10_1_out = data0_in;
    endcase
endmodule   
