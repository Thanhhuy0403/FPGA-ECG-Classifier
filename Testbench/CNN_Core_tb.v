`timescale 1ns/1ns

module TB_CNN_Core;

////////////////////////////////////////////////////////
// PARAMETERS
////////////////////////////////////////////////////////

parameter DATA_WIDTH        = 8;
parameter SCALE_WIDTH       = 31;
parameter WEIGHT_ADDR_WIDTH = 13;
parameter SCALE_ADDR_WIDTH  = 8;
parameter BIAS_ADDR_WIDTH   = 8;
parameter CTX_ADDR_WIDTH    = 6;
parameter CTX_WIDTH         = 30;

parameter PE_NUM            = 10;
parameter PE_NUM_BITS       = 4;
parameter LDM_NUM_BITS      = 2;
parameter LDM_ADDR_WIDTH    = 8;

parameter LDM_DEPTH   = 2560;
parameter CTX_DEPTH   = (1<<CTX_ADDR_WIDTH);
parameter WEIGHT_DEPTH= (1<<WEIGHT_ADDR_WIDTH);
parameter SCALE_DEPTH = (1<<SCALE_ADDR_WIDTH);
parameter BIAS_DEPTH  = (1<<BIAS_ADDR_WIDTH);

////////////////////////////////////////////////////////
// CLOCK
////////////////////////////////////////////////////////

reg iClk;

initial begin
iClk = 0;
forever #5 iClk = ~iClk;
end

////////////////////////////////////////////////////////
// CONTROL
////////////////////////////////////////////////////////

reg iRst;
reg iStart;

////////////////////////////////////////////////////////
// INPUT SIGNALS
////////////////////////////////////////////////////////

reg [DATA_WIDTH-1:0] iECG_signal;
reg [PE_NUM_BITS+LDM_NUM_BITS+LDM_ADDR_WIDTH-1:0] iECG_LDM_addr;
reg iECG_LDM_en_a;
reg iECG_LDM_write_en_a;

reg [CTX_WIDTH-1:0] iCtx;
reg [CTX_ADDR_WIDTH-1:0] iCtx_addr;
reg iCtx_en;
reg iCtx_write_en;

reg [DATA_WIDTH-1:0] iWeight;
reg [WEIGHT_ADDR_WIDTH-1:0] iWeight_addr;
reg iWeight_en;
reg iWeight_write_en;

reg [SCALE_WIDTH-1:0] iScale;
reg [SCALE_ADDR_WIDTH-1:0] iScale_addr;
reg iScale_en;
reg iScale_write_en;

reg [DATA_WIDTH*2-1:0] iBias;
reg [BIAS_ADDR_WIDTH-1:0] iBias_addr;
reg iBias_en;
reg iBias_write_en;

////////////////////////////////////////////////////////
// OUTPUT
////////////////////////////////////////////////////////

wire [DATA_WIDTH-1:0] oData_out;
wire oDone;

////////////////////////////////////////////////////////
// DUT
////////////////////////////////////////////////////////

CNN_Core uut(

.iClk(iClk),
.iRst(iRst),
.iStart(iStart),

.iECG_signal(iECG_signal),
.iECG_LDM_addr(iECG_LDM_addr),
.iECG_LDM_en_a(iECG_LDM_en_a),
.iECG_LDM_write_en_a(iECG_LDM_write_en_a),

.iCtx(iCtx),
.iCtx_addr(iCtx_addr),
.iCtx_en(iCtx_en),
.iCtx_write_en(iCtx_write_en),

.iWeight(iWeight),
.iWeight_addr(iWeight_addr),
.iWeight_en(iWeight_en),
.iWeight_write_en(iWeight_write_en),

.iScale(iScale),
.iScale_addr(iScale_addr),
.iScale_en(iScale_en),
.iScale_write_en(iScale_write_en),

.iBias(iBias),
.iBias_addr(iBias_addr),
.iBias_en(iBias_en),
.iBias_write_en(iBias_write_en),

.oData_out(oData_out),
.oDone(oDone)

);

////////////////////////////////////////////////////////
// TESTBENCH MEMORY
////////////////////////////////////////////////////////

reg [DATA_WIDTH-1:0] ECG_mem   [0:LDM_DEPTH-1];
reg [CTX_WIDTH-1:0]  CTX_mem   [0:CTX_DEPTH-1];
reg [DATA_WIDTH-1:0] WEIGHT_mem[0:WEIGHT_DEPTH-1];
reg [SCALE_WIDTH-1:0] SCALE_mem[0:SCALE_DEPTH-1];
reg [DATA_WIDTH*2-1:0] BIAS_mem[0:BIAS_DEPTH-1];
reg [DATA_WIDTH-1:0] out_mem [0:LDM_DEPTH-1];

////////////////////////////////////////////////////////
// READ FILE
////////////////////////////////////////////////////////

initial begin
$readmemh("ecg.mem",ECG_mem);
$readmemh("context.mem",CTX_mem);
$readmemh("weight.mem",WEIGHT_mem);
$readmemh("scale.mem",SCALE_mem);
$readmemh("bias.mem",BIAS_mem);
end

////////////////////////////////////////////////////////
// SIMULATION
////////////////////////////////////////////////////////

integer i;
integer pe_id;
integer ldm_addr;
integer outfile;

initial begin

////////////////////////////////////////////////////////
// INIT
////////////////////////////////////////////////////////

iRst = 0;
iStart = 0;

iECG_signal = 0;
iECG_LDM_addr = 0;
iECG_LDM_en_a = 0;
iECG_LDM_write_en_a = 0;

iCtx = 0;
iCtx_addr = 0;
iCtx_en = 0;
iCtx_write_en = 0;

iWeight = 0;
iWeight_addr = 0;
iWeight_en = 0;
iWeight_write_en = 0;

iScale = 0;
iScale_addr = 0;
iScale_en = 0;
iScale_write_en = 0;

iBias = 0;
iBias_addr = 0;
iBias_en = 0;
iBias_write_en = 0;

////////////////////////////////////////////////////////
// RESET
////////////////////////////////////////////////////////

#20
iRst = 1;

////////////////////////////////////////////////////////
// LOAD ECG
////////////////////////////////////////////////////////
for(i=0;i<340;i=i+1) begin

    pe_id    = i % PE_NUM;
    ldm_addr = i / PE_NUM;

    iECG_LDM_addr <= {pe_id[PE_NUM_BITS-1:0],2'd0,ldm_addr[LDM_ADDR_WIDTH-1:0]};
    iECG_signal   <= ECG_mem[i];

    iECG_LDM_en_a <= 1;
    iECG_LDM_write_en_a <= 1;

    @(posedge iClk);

end

iECG_LDM_en_a = 0;
iECG_LDM_write_en_a = 0;

#50

////////////////////////////////////////////////////////
// LOAD CONTEXT
////////////////////////////////////////////////////////

for(i=0;i<CTX_DEPTH;i=i+1) begin
@(posedge iClk);
iCtx_en = 1;
iCtx_write_en = 1;
iCtx_addr = i;
iCtx = CTX_mem[i];
end

@(posedge iClk);
iCtx_en = 0;
iCtx_write_en = 0;

////////////////////////////////////////////////////////
// LOAD WEIGHT
////////////////////////////////////////////////////////

for(i=0;i<WEIGHT_DEPTH;i=i+1) begin
@(posedge iClk);
iWeight_en = 1;
iWeight_write_en = 1;
iWeight_addr = i;
iWeight = WEIGHT_mem[i];
end

@(posedge iClk);
iWeight_en = 0;
iWeight_write_en = 0;

////////////////////////////////////////////////////////
// LOAD SCALE
////////////////////////////////////////////////////////

for(i=0;i<SCALE_DEPTH;i=i+1) begin
@(posedge iClk);
iScale_en = 1;
iScale_write_en = 1;
iScale_addr = i;
iScale = SCALE_mem[i];
end

@(posedge iClk);
iScale_en = 0;
iScale_write_en = 0;

////////////////////////////////////////////////////////
// LOAD BIAS
////////////////////////////////////////////////////////

for(i=0;i<BIAS_DEPTH;i=i+1) begin
@(posedge iClk);
iBias_en = 1;
iBias_write_en = 1;
iBias_addr = i;
iBias = BIAS_mem[i];
end

@(posedge iClk);
iBias_en = 0;
iBias_write_en = 0;


////////////////////////////////////////////////////////
// START CORE
////////////////////////////////////////////////////////

#20
iStart = 1;
#10
iStart = 0;

////////////////////////////////////////////////////////
// WAIT DONE
////////////////////////////////////////////////////////
outfile = $fopen("out.mem", "w");

wait(oDone == 1'b1);
#100;

    
for(i=0;i<1281;i=i+1) begin

    pe_id    = i / PE_NUM;
    ldm_addr = (i + pe_id * 6) & 16'hFFFF;
    iECG_LDM_en_a = 1;
    iECG_LDM_addr = {ldm_addr[PE_NUM_BITS-1:0],2'd0,ldm_addr[PE_NUM_BITS+LDM_ADDR_WIDTH-1:PE_NUM_BITS]};
//    iECG_signal   <= ECG_mem[i];
//    out_mem[i]   <= oData_out;


    iECG_LDM_write_en_a = 0;
    @(posedge iClk);
    // Write to file instead of just displaying
	if(i>=1)
        $fwrite(outfile, "%02h\n", oData_out);

end

iECG_LDM_en_a <= 0;
$fclose(outfile);

////////////////////////////////////////////////////////
// SAVE OUTPUT
////////////////////////////////////////////////////////

//outfile = $fopen("out.mem","w");

//for(i=0;i<1280;i=i+1) begin
//@(posedge iClk);
//$fwrite(outfile,"%02h\n",oData_out);
//end

//$fclose(outfile);

$display("Simulation finished");
$stop;

end

endmodule
