`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:41:29 PM
// Design Name: 
// Module Name: MAX
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

module max
#(parameter DATA_WIDTH=8)
(
    input                           iClk,
    input                           iRst,
    input                           iS0_valid,
    input  signed  [DATA_WIDTH-1:0] iS0,
    input                           iS1_valid,
    input  signed  [DATA_WIDTH-1:0] iS1,
    input                           iS2_valid,
    input  signed  [DATA_WIDTH-1:0] iS2,
    output                          oD0_valid,
    output signed  [DATA_WIDTH-1:0] oD0
);

    
    reg signed [DATA_WIDTH-1:0] S0_reg;
    reg signed [DATA_WIDTH-1:0] S1_reg;
    reg signed [DATA_WIDTH-1:0] S2_reg;
    reg signed [DATA_WIDTH-1:0] D0_reg;
    
    reg                   S0_valid_reg;
    reg                   S1_valid_reg; 
    reg                   S2_valid_reg;
    reg                   D0_valid_reg;
    
    wire signed [DATA_WIDTH-1:0] max1_wire; 
    wire signed [DATA_WIDTH-1:0] max2_wire;
    
    assign oD0          = D0_reg;
    assign oD0_valid    = D0_valid_reg;
    assign max1_wire    = (S0_reg < S1_reg) ? S1_reg : S0_reg;
    assign max2_wire    = (max1_wire < S2_reg) ? S2_reg: max1_wire;
    
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            S0_valid_reg  <= 1'b0;
            S1_valid_reg  <= 1'b0;
            S2_valid_reg  <= 1'b0;
            S0_reg        <= {DATA_WIDTH{1'b0}};
            S1_reg        <= {DATA_WIDTH{1'b0}};
            S2_reg        <= {DATA_WIDTH{1'b0}};
            D0_valid_reg  <= 1'b0;
            D0_reg        <= {DATA_WIDTH{1'b0}};
        end
        else begin
            S0_valid_reg  <= iS0_valid;
            S1_valid_reg  <= iS1_valid;
            S2_valid_reg  <= iS2_valid;
            S0_reg        <= iS0;
            S1_reg        <= iS1;
            S2_reg        <= iS2;  
            D0_reg        <= max2_wire;         
            D0_valid_reg  <= S0_valid_reg && S1_valid_reg && S2_valid_reg;
        end
    end
    
endmodule

