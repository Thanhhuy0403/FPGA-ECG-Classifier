`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:45:47 PM
// Design Name: 
// Module Name: Dual_Port_RAM
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


//module Dual_Port_RAM #(parameter DATA_WIDTH=8,ADDR_WIDTH=8)
//(
//    input                     iClk,
//    //-------------------------PORT A----------------------//
//    input                     iEn_a,
//    input                     iWrite_en_a,
//    input  [ADDR_WIDTH-1:0]   iAddr_a,
//    input  [DATA_WIDTH-1:0]   iData_a,
//    output [DATA_WIDTH-1:0]   oData_a,
//    //-------------------------PORT_b----------------------//
//    input                     iEn_b,
//    input                     iWrite_en_b,
//    input  [ADDR_WIDTH-1:0]   iAddr_b,
//    input  [DATA_WIDTH-1:0]   iData_b,
//    output [DATA_WIDTH-1:0]   oData_b
//    );
//    reg [DATA_WIDTH-1:0]Data_out_a;
//    reg [DATA_WIDTH-1:0]Data_out_b;
//    reg [DATA_WIDTH-1:0]mem[2**ADDR_WIDTH-1:0];
    
//    assign oData_a = Data_out_a;
//    assign oData_b = Data_out_b;

//    always @(posedge iClk) begin
//        if (iEn_a) begin
//            if (iWrite_en_a) begin
//                mem[iAddr_a] <= iData_a;
//            end
//            Data_out_a <= mem[iAddr_a];
//        end         
//    end
//    always @(posedge iClk) begin
//        if (iEn_b) begin
//            if (iWrite_en_b) begin
//                mem[iAddr_b] <= iData_b;
//            end
//            Data_out_b <= mem[iAddr_b];
//        end         
//    end
//endmodule
module Dual_Port_RAM
#(
  parameter ADDR_WIDTH = 8, // address width
  parameter DATA_WIDTH = 8 // data width
)
(
  input iClk, // clock
  ///*** Port A***///
  input iEn_a, // port A read enable
  input iWrite_en_a, // port A write enable
  input [ADDR_WIDTH-1:0] iAddr_a, // port A address
  input [DATA_WIDTH-1:0] iData_a, // port A data
  output reg [DATA_WIDTH-1:0] oData_a, // port A data output
  
  ///*** Port B***///
  input iEn_b, // port A read enable
  input iWrite_en_b, // port A write enable
  input [ADDR_WIDTH-1:0] iAddr_b, // port A address
  input [DATA_WIDTH-1:0] iData_b, // port A data
  output reg [DATA_WIDTH-1:0] oData_b // port A data output
);

	reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

	always @(posedge iClk) begin
		// /*** Port A***///
		if (iEn_a&iEn_b) begin
			if(iWrite_en_a) begin
				mem[iAddr_a] <= iData_a;
			end
			else if(iWrite_en_b) begin
				mem[iAddr_b] <= iData_b;
			end
			
			oData_a <= mem[iAddr_a];
			oData_b <= mem[iAddr_b];
		end
		else if(iEn_a) begin
			if(iWrite_en_a) begin
				mem[iAddr_a] <= iData_a;
			end
			oData_a <= mem[iAddr_a];
		end
		else if (iEn_b) begin
			if(iWrite_en_b) begin
				mem[iAddr_b] <= iData_b;
			end
			oData_b <= mem[iAddr_b];
		end
		
	end
	
endmodule