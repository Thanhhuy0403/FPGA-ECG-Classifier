`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:41:39 PM
// Design Name: 
// Module Name: LSU
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


module LSU
#(parameter DATA_WIDTH = 8,
            ADDR_WIDTH = 8,
            LDM_NUM_BITS = 2,
            LDM_NUM = 3
            
)
(
    input iClk,
    input iRst,

    input iPadding_en,

    input [DATA_WIDTH-1:0] iData_a,
    input iEn_a,
    input iWrite_en_a,
    input [LDM_NUM_BITS+ADDR_WIDTH-1:0] iAddr_a,

    input [LDM_NUM_BITS+ADDR_WIDTH-1:0] iCTRL_Addr_a,
    input [LDM_NUM_BITS+ADDR_WIDTH-1:0] iCTRL_Addr_b,
    input iCTRL_write_en_a,
    input iCTRL_write_en_b,
    input iCTRL_en_a,
    input iCTRL_en_b,

    input [LDM_NUM_BITS+ADDR_WIDTH-1:0] iALU_Addr_b,
    input [DATA_WIDTH-1:0] iALU_Data_b,
    input iALU_en_b,
    input iALU_write_en_b,

    output [DATA_WIDTH-1:0] oPixel_0,
    output oPixel_valid_0,
    output [DATA_WIDTH-1:0] oPixel_1,
    output oPixel_valid_1,
    output [DATA_WIDTH-1:0] oData_Pixel
    
);  

    // LDM0 wire signals
    wire [DATA_WIDTH-1:0] LDM0_Data_a_in, LDM0_Data_b_in;
    wire [ADDR_WIDTH-1:0] LDM0_Addr_a, LDM0_Addr_b;
    wire [DATA_WIDTH-1:0] LDM0_Data_a_out, LDM0_Data_b_out;
    wire LDM0_Write_en_a, LDM0_Write_en_b;
    wire LDM0_En_a, LDM0_En_b;
    // LDM1 wire signals
    wire [DATA_WIDTH-1:0] LDM1_Data_a_in, LDM1_Data_b_in;
    wire [ADDR_WIDTH-1:0] LDM1_Addr_a, LDM1_Addr_b;
    wire [DATA_WIDTH-1:0] LDM1_Data_a_out, LDM1_Data_b_out;
    wire LDM1_Write_en_a, LDM1_Write_en_b;
    wire LDM1_En_a, LDM1_En_b;
    //LDM2 wire signals
    wire [DATA_WIDTH-1:0] LDM2_Data_a_in, LDM2_Data_b_in;
    wire [ADDR_WIDTH-1:0] LDM2_Addr_a, LDM2_Addr_b;
    wire [DATA_WIDTH-1:0] LDM2_Data_a_out, LDM2_Data_b_out;
    wire LDM2_Write_en_a, LDM2_Write_en_b;
    wire LDM2_En_a, LDM2_En_b;
    //LDM0 reg signals
    reg LDM0_Write_en_a_reg, LDM0_Write_en_b_reg;
    reg LDM0_En_a_reg, LDM0_En_b_reg;
    // LDM1 reg signals
    reg LDM1_Write_en_a_reg, LDM1_Write_en_b_reg;
    reg LDM1_En_a_reg, LDM1_En_b_reg;
    // LDM2 reg signals
    reg LDM2_Write_en_a_reg, LDM2_Write_en_b_reg;
    reg LDM2_En_a_reg, LDM2_En_b_reg;

    reg [1:0] Select_LDM_reg_a;
    reg [1:0] Select_LDM_reg_b;
    reg Padding_en_reg;
    
    reg [LDM_NUM_BITS+ADDR_WIDTH-1:0] Data_pixel_addr;
    reg en_a_reg;

//================ LDM0 =================
assign LDM0_Write_en_a = (iEn_a      && iWrite_en_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 0) ||
                         (iCTRL_en_a && iCTRL_write_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0);

assign LDM0_Write_en_b = (iCTRL_en_b && iCTRL_write_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0) ||
                         (iALU_en_b  && iALU_write_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 0);

assign LDM0_En_a = (iEn_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 0) ||
                   (iCTRL_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0);

assign LDM0_En_b = (iCTRL_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0) ||
                   (iALU_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 0);

assign LDM0_Addr_a =
        (iEn_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 0) ? iAddr_a[ADDR_WIDTH-1:0] :
        (iCTRL_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0) ? iCTRL_Addr_a[ADDR_WIDTH-1:0] : 0;

assign LDM0_Addr_b =
        (iCTRL_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0) ? iCTRL_Addr_b[ADDR_WIDTH-1:0] :
        (iALU_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 0) ? iALU_Addr_b[ADDR_WIDTH-1:0] : 0;

assign LDM0_Data_a_in = (iEn_a && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0) ? iData_a : 0;
assign LDM0_Data_b_in = iALU_Data_b;


//================ LDM1 =================
assign LDM1_Write_en_a = (iEn_a      && iWrite_en_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 1) ||
                         (iCTRL_en_a && iCTRL_write_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1);

assign LDM1_Write_en_b = (iCTRL_en_b && iCTRL_write_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1) ||
                         (iALU_en_b  && iALU_write_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 1);

assign LDM1_En_a = (iEn_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 1) ||
                   (iCTRL_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1);

assign LDM1_En_b = (iCTRL_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1) ||
                   (iALU_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 1);

assign LDM1_Addr_a =
        (iEn_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 1) ? iAddr_a[ADDR_WIDTH-1:0] :
        (iCTRL_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1) ? iCTRL_Addr_a[ADDR_WIDTH-1:0] : 0;

assign LDM1_Addr_b =
        (iCTRL_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1) ? iCTRL_Addr_b[ADDR_WIDTH-1:0] :
        (iALU_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 1) ? iALU_Addr_b[ADDR_WIDTH-1:0] : 0;

assign LDM1_Data_a_in = (iEn_a && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1) ? iData_a : 0;
assign LDM1_Data_b_in = iALU_Data_b;


//================ LDM2 =================
assign LDM2_Write_en_a = (iEn_a      && iWrite_en_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 2) ||
                         (iCTRL_en_a && iCTRL_write_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2);

assign LDM2_Write_en_b = (iCTRL_en_b && iCTRL_write_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2) ||
                         (iALU_en_b  && iALU_write_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 2);

assign LDM2_En_a = (iEn_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 2) ||
                   (iCTRL_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2);

assign LDM2_En_b = (iCTRL_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2) ||
                   (iALU_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 2);

assign LDM2_Addr_a =
        (iEn_a      && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]      == 2) ? iAddr_a[ADDR_WIDTH-1:0] :
        (iCTRL_en_a && iCTRL_Addr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2) ? iCTRL_Addr_a[ADDR_WIDTH-1:0] : 0;

assign LDM2_Addr_b =
        (iCTRL_en_b && iCTRL_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2) ? iCTRL_Addr_b[ADDR_WIDTH-1:0] :
        (iALU_en_b  && iALU_Addr_b[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH]  == 2) ? iALU_Addr_b[ADDR_WIDTH-1:0] : 0;

assign LDM2_Data_a_in = (iEn_a && iAddr_a[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2) ? iData_a : 0;
assign LDM2_Data_b_in = iALU_Data_b;

Dual_Port_RAM #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) LDM_0(
    .iClk(iClk),

    .iAddr_a(LDM0_Addr_a),
    .iAddr_b(LDM0_Addr_b),

    .iData_a(LDM0_Data_a_in),
    .iData_b(LDM0_Data_b_in),

    .iWrite_en_a(LDM0_Write_en_a),
    .iWrite_en_b(LDM0_Write_en_b),

    .iEn_a(LDM0_En_a),
    .iEn_b(LDM0_En_b),
    
    .oData_a(LDM0_Data_a_out),
    .oData_b(LDM0_Data_b_out)
);

Dual_Port_RAM #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) LDM_1(
    .iClk(iClk),

    .iAddr_a(LDM1_Addr_a),
    .iAddr_b(LDM1_Addr_b),

    .iData_a(LDM1_Data_a_in),
    .iData_b(LDM1_Data_b_in),

    .iWrite_en_a(LDM1_Write_en_a),
    .iWrite_en_b(LDM1_Write_en_b),

    .iEn_a(LDM1_En_a),
    .iEn_b(LDM1_En_b),
    
    .oData_a(LDM1_Data_a_out),
    .oData_b(LDM1_Data_b_out)
);

Dual_Port_RAM #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
)    
LDM2(
    .iClk(iClk),

    .iAddr_a(LDM2_Addr_a),
    .iAddr_b(LDM2_Addr_b),

    .iData_a(LDM2_Data_a_in),
    .iData_b(LDM2_Data_b_in),

    .iWrite_en_a(LDM2_Write_en_a),
    .iWrite_en_b(LDM2_Write_en_b),

    .iEn_a(LDM2_En_a),
    .iEn_b(LDM2_En_b),
    
    .oData_a(LDM2_Data_a_out),
    .oData_b(LDM2_Data_b_out) 
);

    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            // LDM0 regs reset
            LDM0_Write_en_a_reg<= 0;
            LDM0_Write_en_b_reg<= 0;
            LDM0_En_a_reg      <= 0;
            LDM0_En_b_reg      <= 0;
            // LDM1 regs reset
            LDM1_Write_en_a_reg<= 0;
            LDM1_Write_en_b_reg<= 0;
            LDM1_En_a_reg      <= 0;
            LDM1_En_b_reg      <= 0;
            // LDM2 regs reset
            LDM2_Write_en_a_reg<= 0;
            LDM2_Write_en_b_reg<= 0;
            LDM2_En_a_reg      <= 0;
            LDM2_En_b_reg      <= 0;
            // LDM3 regs reset

            Select_LDM_reg_a   <= 0;
            Select_LDM_reg_b   <= 0;
            Padding_en_reg     <= 0;
            Data_pixel_addr    <= 0;
            en_a_reg      <= 0; 
        end 
        else begin
            // LDM0 regs
            LDM0_Write_en_a_reg<= LDM0_Write_en_a;
            LDM0_Write_en_b_reg<= LDM0_Write_en_b;
            LDM0_En_a_reg      <= LDM0_En_a;
            LDM0_En_b_reg      <= LDM0_En_b;
            // LDM1 regs
            LDM1_Write_en_a_reg<= LDM1_Write_en_a;
            LDM1_Write_en_b_reg<= LDM1_Write_en_b;
            LDM1_En_a_reg      <= LDM1_En_a;
            LDM1_En_b_reg      <= LDM1_En_b;
            // LDM2 regs
            LDM2_Write_en_a_reg<= LDM2_Write_en_a;
            LDM2_Write_en_b_reg<= LDM2_Write_en_b;
            LDM2_En_a_reg      <= LDM2_En_a;
            LDM2_En_b_reg      <= LDM2_En_b;
            
            Select_LDM_reg_a   <= iCTRL_Addr_a[LDM_NUM_BITS + ADDR_WIDTH - 1: ADDR_WIDTH];
            Select_LDM_reg_b   <= iCTRL_Addr_b[LDM_NUM_BITS + ADDR_WIDTH - 1: ADDR_WIDTH];
            Padding_en_reg     <= iPadding_en;
            Data_pixel_addr    <= iAddr_a;
            en_a_reg           <= iEn_a;
        end
    end

    assign oPixel_0 = (Select_LDM_reg_a == 0 ) ? LDM0_Data_a_out : (Select_LDM_reg_a == 1) ? LDM1_Data_a_out : (Select_LDM_reg_a == 2) ? LDM2_Data_a_out : 0;
    assign oPixel_1 = (Select_LDM_reg_b == 0 ) ? LDM0_Data_b_out : (Select_LDM_reg_b == 1) ? LDM1_Data_b_out : (Select_LDM_reg_b == 2) ? LDM2_Data_b_out : 0;
    
    assign oPixel_valid_0 = (Select_LDM_reg_a == 0 ) ? (LDM0_En_a_reg && ~LDM0_Write_en_a_reg) : 
                            (Select_LDM_reg_a == 1 ) ? (LDM1_En_a_reg && ~LDM1_Write_en_a_reg) :
                            (Select_LDM_reg_a == 2 ) ? (LDM2_En_a_reg && ~LDM2_Write_en_a_reg) : 0;
                            

    assign oPixel_valid_1 = (Select_LDM_reg_b == 0 ) ? (LDM0_En_b_reg && ~LDM0_Write_en_b_reg)  : 
                            (Select_LDM_reg_b == 1 ) ? (LDM1_En_b_reg && ~LDM1_Write_en_b_reg)  :
                            (Select_LDM_reg_b == 2 ) ? (LDM2_En_b_reg && ~LDM2_Write_en_b_reg)  : 0;
                            
    assign oData_Pixel = (Data_pixel_addr[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 0 && en_a_reg) ? LDM0_Data_a_out :
                         (Data_pixel_addr[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 1 && en_a_reg) ? LDM1_Data_a_out :
                         (Data_pixel_addr[LDM_NUM_BITS+ADDR_WIDTH-1:ADDR_WIDTH] == 2 && en_a_reg) ? LDM2_Data_a_out : 0;

endmodule
