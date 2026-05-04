`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 06:12:28 PM
// Design Name: 
// Module Name: MAC_tb
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


module MAC_tb;

parameter DATA_WIDTH = 8;

reg iClk, iRst;
reg signed [DATA_WIDTH-1:0] iS0, iS1;
reg signed [DATA_WIDTH*2-1:0] iS2;
reg iS0_valid, iS1_valid, iS2_valid;
reg iReLU_en;
reg signed [DATA_WIDTH-1:0] iZero_point;

wire signed [DATA_WIDTH*2-1:0] oD0;
wire oD0_valid;

// Instantiate MAC
MAC #(.DATA_WIDTH(DATA_WIDTH)) uut (
    .iClk(iClk),
    .iRst(iRst),
    .iS0(iS0),
    .iS1(iS1),
    .iS2(iS2),
    .iS0_valid(iS0_valid),
    .iS1_valid(iS1_valid),
    .iS2_valid(iS2_valid),
    .oD0(oD0),
    .oD0_valid(oD0_valid)
);

// Clock
always #5 iClk = ~iClk;

// Test
initial begin
    // Init
    iClk = 0;
    iRst = 0;
    iS0 = 0;
    iS1 = 0;
    iS2 = 0;
    iS0_valid = 0;
    iS1_valid = 0;
    iS2_valid = 0;
    iReLU_en = 0;
    iZero_point = -128;

    // Reset
    #20;
    iRst = 1;

    // =========================
    // MAC sequence
    // =========================

    // Cycle 1
    @(negedge iClk);
    iS0 <= -21;
    iS1 <= 127;
    iS2 <= 0;
    iS0_valid <= 1;
    iS1_valid <= 1;
    iS2_valid <= 0;
    iReLU_en <= 0;

    // Cycle 2
    @(negedge iClk);
    iS0 <= -21;
    iS1 <= 63;
    iS2 <= 0;
    iS2_valid <= 0;

    // Cycle 3
    @(negedge iClk);
    iS0 <= -20;
    iS1 <= 35;
    iS2 <= 0;
    iS2_valid <= 0;

    // Cycle cuối (add bias + trigger output)
    @(negedge iClk);
    iS0 <= -21;
    iS1 <= 55;
    iS2 <= -780;   // bias
    iS2_valid <= 1;
    iReLU_en <= 1;

    // stop input
    @(negedge iClk);
    iS0_valid <= 0;
    iS1_valid <= 0;
    iS2_valid <= 0;

    // wait
    #50;
    $stop;
end

endmodule