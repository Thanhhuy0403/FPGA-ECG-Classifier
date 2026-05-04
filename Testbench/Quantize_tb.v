`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 10:27:57 AM
// Design Name: 
// Module Name: Quantize_tb
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

module quantize_tb;

    reg                iClk;
    reg                iRst;
    reg  signed [24:0] iR;
    reg         [4:0]  iNum_bit;       
    reg         [15:0] iScale; 
    reg  signed [15:0] iZero_point;
    reg iReLU_en;
    wire signed [7:0]  oQ;
    
    quantize uut (
        .iClk(iClk),
        .iRst(iRst),
        .iR(iR),
        .iReLU_en(iReLU_en),
        .iNum_bit(iNum_bit),       
        .iScale(iScale), 
        .iZero_point(iZero_point),
        .oQ(oQ)
    );    
    always begin 
        #5 iClk <= ~iClk;
    end
    
    initial begin
        iReLU_en <= 0;
        iClk <= 0;
        iRst <= 0;
        iR   <= 0;
        iNum_bit <= 0;
        iScale <= 0;
        iZero_point <= 0;
    end
    
    initial begin
        #10
        iRst <= 1;
        #10
        iR   <= 108;
        iNum_bit <= 15;
        iScale <= 131;
        iZero_point <= -1;
        #10
        iR   <= 15;
        iNum_bit <= 13;
        iScale <= 64990;
        iZero_point <= 0;           
    end
endmodule
