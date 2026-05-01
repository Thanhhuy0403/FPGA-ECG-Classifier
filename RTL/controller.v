`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:53:08 PM
// Design Name: 
// Module Name: controller
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 06:53:08 PM
// Design Name: 
// Module Name: controller
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
module controller
#(parameter DATA_WIDTH = 8,
            WEIGHT_ADDR_WIDTH = 13,
            SCALE_ADDR_WIDTH = 8,
            BIAS_ADDR_WIDTH = 8,
            CTX_ADDR_WIDTH = 6,
            PE_NUM = 10,
            PE_NUM_BITS = 4,
            LDM_ADDR_WIDTH = 8,
            LDM_NUM_BITS = 2
) 
(
    input iClk,
    input iRst,
    input iStart,
    input [29:0] iCtx,

    output [WEIGHT_ADDR_WIDTH-1:0] oWeight_addr,
    output        oWeight_write_en,
    output        oWeight_en,

    output [SCALE_ADDR_WIDTH-1:0]  oScale_addr,
    output        oScale_en,
    output        oScale_write_en,

    output [BIAS_ADDR_WIDTH-1:0] oBias_addr,
    output        oBias_write_en,
    output        oBias_en,

    output [CTX_ADDR_WIDTH-1:0]  oCtx_addr,
    output        oCtx_en,
    output        oCtx_write_en,

    output [3:0]  oMux_select,

    output [LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0] oLDM_addr_a,
    output        oLDM_en_a,
    output        oCTRL_LDM_write_en_a,
    output [LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0] oLDM_addr_b,
    output        oLDM_en_b,
    output        oCTRL_LDM_write_en_b,
    output [LDM_NUM_BITS + LDM_ADDR_WIDTH-1:0] oALU_LDM_addr_store,
    
    output        oMP_padding_FP,
    output        oMP_padding_LP,
    output        oMP_padding_LP_First,
    output        oReLU_en,
    output        oStride,
    output        oPU_en,
    output [PE_NUM-1:0]  oPadding_en,
    output [PE_NUM-1:0]  oIncrement_addr_en,
    output oPU_mode,
    output [1:0] oCfg,
    
    output oLayer_done,
    output oDone

);

    localparam IDLE       = 2'b00;
    localparam LOAD_CTX   = 2'b01;
    localparam EXECUTE    = 2'b10;

    localparam CONV = 2'b00;
    localparam MP   = 2'b01;
    localparam ADD  = 2'b10;

    reg [2:0] current_state;
    
    wire stride;
    wire layer_done_wire;
    wire done_wire;
    wire [2:0] J; // input Kernel_size
    wire [4:0] K; // input channel
    wire [4:0] N; // output channel
    wire [4:0] Y; // output position index
    wire [1:0] padding;
    wire    ReLU_en;
    wire [1:0] cfg;
    wire [1:0] Source_LDM;
    wire [1:0] Destination_LDM;
    wire [LDM_ADDR_WIDTH-1:0] Start_LDM;

    wire [PE_NUM_BITS-1:0] Padding_select;
    wire [PE_NUM_BITS-1:0] Increment_addr_select;
    wire [LDM_ADDR_WIDTH-1:0] LDM_addr_offset;
    wire [PE_NUM_BITS-1:0] Increment_addr;
    wire conv_en;
    wire [PE_NUM_BITS-1:0] MUX_select; 
    wire [LDM_ADDR_WIDTH-1:0] LDM_addr_a;
    wire [LDM_ADDR_WIDTH-1:0] LDM_addr_b;
    
    reg next_ctx_en_reg_1;
    reg next_ctx_en_reg_2;
    reg next_ctx_en_reg_3;
    reg next_ctx_en_reg_4;
    //______________ Layer Counters ______________//
    reg [2:0] j_reg;
    reg [4:0] k_reg;
    reg [4:0] n_reg;
    reg [4:0] y_reg;

    reg [PE_NUM-1:0]CTRL_LDM_Incr_reg;
    //______________ REG Weight Memory ______________//
    reg [WEIGHT_ADDR_WIDTH-1:0] Weight_addr_offset;
    reg [WEIGHT_ADDR_WIDTH-1:0] Weight_addr_start;
    //______________ REG Bias Memory ______________//
    reg [BIAS_ADDR_WIDTH-1:0] Bias_addr;
    //______________ REG Ctx Memory ______________//
    reg [CTX_ADDR_WIDTH-1:0] Ctx_addr;
    //______________ LDM MEMORY ______________//
    reg [LDM_ADDR_WIDTH-1:0] LDM_addr;
    reg [LDM_ADDR_WIDTH-1:0] LDM_addr_cnt_y;
    //______________REG Scale Memory______________//
    reg [SCALE_ADDR_WIDTH-1:0] Scale_addr;
    reg [PE_NUM-1:0] Padding_en_reg;
    
    
    assign Y = iCtx[29:25]; 
    assign K = iCtx[24:20];    
    assign J = iCtx[19:17];
    assign N = iCtx[16:12]; 
    assign stride = iCtx[11:11];
    assign padding = iCtx[10:9];
    assign Source_LDM = iCtx[8:7];
    assign Destination_LDM = iCtx[6:5];   
    assign Start_LDM = iCtx[4:3] << 5;     
    assign ReLU_en = iCtx[2:2];
    assign cfg = iCtx[1:0];
    
    assign conv_en = (cfg == CONV) ? 1'b1 : 1'b0;

    assign layer_done_wire = next_ctx_en_reg_4;
    assign done_wire = layer_done_wire && (Ctx_addr >= 42); // cần sửa ctx_addr bằng với số addr tối đa của context RAM.
    assign LDM_addr_offset = Y + 1;
    //___________________To Padding PE______________________//
    assign Padding_select =((y_reg == 0 ) && (j_reg < padding)) ? PE_NUM - padding + j_reg : ((padding != 0) && (y_reg == Y) && (j_reg >= (J - padding))) ? j_reg - padding - 1 : 15;
    assign Increment_addr_select = (padding == 0) ? 0 : PE_NUM - padding;
    assign Increment_addr = ((Increment_addr_select + (j_reg)) >= PE_NUM) ? Increment_addr_select + (j_reg) - PE_NUM: Increment_addr_select + (j_reg);
    assign oMP_padding_FP = (y_reg == Y) && (cfg == MP) ? (padding[0])  : 0;
    assign oMP_padding_LP = (y_reg == 0) && (cfg == MP) ? (padding[0]) : 0;
    assign oMP_padding_LP_First = (y_reg == 0) && (n_reg == 0) && (cfg == MP) ? (padding[0]) : 0;
    assign MUX_select = (j_reg < padding) ? PE_NUM - padding + j_reg : j_reg - padding;

    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            current_state <= 0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    if (iStart) begin
                        current_state <= LOAD_CTX;
                    end else begin
                        current_state <= IDLE;
                    end
                end
                LOAD_CTX: begin
                    current_state <= EXECUTE;
                end
                EXECUTE: begin
                    if (done_wire) begin
                        current_state <= IDLE;
                    end
                    else if (layer_done_wire) begin 
                        current_state <= LOAD_CTX;   
                    end
                    else begin
                        current_state <= EXECUTE;
                    end
                end
                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end

    always @(posedge iClk or negedge  iRst) begin
        if (~iRst) begin
            // reset outputs
            j_reg <= 0;
            k_reg <= 0;
            n_reg <= 0;
            y_reg <= 0;
            Weight_addr_offset <= 0;
            Weight_addr_start <= 0;
            LDM_addr_cnt_y <= 0;
            LDM_addr <= 0;
            Scale_addr <= 0;
            Bias_addr <= 0;
            CTRL_LDM_Incr_reg <= 0;
            next_ctx_en_reg_1 <= 0;
            next_ctx_en_reg_2 <= 0;
            next_ctx_en_reg_3 <= 0;
            next_ctx_en_reg_4 <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    j_reg <= 0;
                    k_reg <= 0;
                    n_reg <= 0;
                    y_reg <= 0;
                    Weight_addr_offset <= 0;
                    Weight_addr_start <= 0;
                    LDM_addr_cnt_y <= 0;
                    LDM_addr <= 0;
                    Scale_addr <= 0;
                    Bias_addr <= 0;
                    LDM_addr <= 0;
                    CTRL_LDM_Incr_reg <= 0;
                    next_ctx_en_reg_1 <= 0;
                    next_ctx_en_reg_2 <= 0;
                    next_ctx_en_reg_3 <= 0;
                    next_ctx_en_reg_4 <= 0;
                end
                LOAD_CTX: begin
                    j_reg <= 0;
                    k_reg <= 0;
                    n_reg <= 0;
                    y_reg <= 0;
                    Weight_addr_offset <= 0;
                    LDM_addr_cnt_y <= 0;
                    Weight_addr_start <= Weight_addr_start;
                    Scale_addr <= Scale_addr;
                    Bias_addr <= Bias_addr;
                    LDM_addr <= 0;
                    CTRL_LDM_Incr_reg <= 0;
                    Scale_addr <= Scale_addr;
                    next_ctx_en_reg_1 <= 0;
                    next_ctx_en_reg_2 <= 0;
                    next_ctx_en_reg_3 <= 0;
                    next_ctx_en_reg_4 <= 0;
                end
                EXECUTE: begin
                    if (j_reg == J) begin
                        j_reg <= 0;
                        CTRL_LDM_Incr_reg <= 0;
                        if (k_reg == K) begin
                            k_reg <= 0;
                            Weight_addr_offset <= 0;
                            if (conv_en) begin
                                LDM_addr <= 0;
                            end
                            else begin
                                LDM_addr <= LDM_addr+1+stride;
                            end
                            if (y_reg == Y) begin
                                y_reg <= 0;
                                LDM_addr_cnt_y <= 0;
                                if (n_reg == N) begin
                                    n_reg <= 0;
                                    Bias_addr <= Bias_addr + conv_en;
                                    Scale_addr <= Scale_addr + conv_en;
                                end else begin
                                    n_reg <= n_reg + 1;
                                    Bias_addr <= Bias_addr + conv_en;
                                    Scale_addr <= Scale_addr + conv_en;
                                end
                            end else begin
                                y_reg <= y_reg + 1;
                                if (conv_en) begin
                                    LDM_addr_cnt_y <= LDM_addr_cnt_y + 1 + stride;
                                end
                                else begin
                                    LDM_addr_cnt_y <= LDM_addr_cnt_y;
                                end 
                            end
                        end else begin
                            k_reg <= k_reg + 1;
                            LDM_addr <= LDM_addr + LDM_addr_offset;
                            Weight_addr_offset <= Weight_addr_offset + conv_en;

                        end
                    end else begin
                        j_reg <= j_reg + 1; 

                        Weight_addr_offset <= Weight_addr_offset + conv_en;

                        k_reg <= k_reg;
                        n_reg <= n_reg;
                        y_reg <= y_reg;   
                        CTRL_LDM_Incr_reg[Increment_addr] <= 1'b1;
                    end

                    if ((j_reg == J) && (k_reg == K) && (y_reg == Y) && (n_reg == N)) begin
                        next_ctx_en_reg_1 <= 1;
                    end
                    else begin
                        next_ctx_en_reg_1 <= 0;
                    end
                    if ((j_reg == J) && (k_reg == K) && (y_reg == Y)) begin
                        Weight_addr_start <= Weight_addr_start + Weight_addr_offset + conv_en; // Cộng hết weight đang có và cộng thêm 1.
                    end
                    next_ctx_en_reg_2 <= next_ctx_en_reg_1 ;
                    next_ctx_en_reg_3 <= next_ctx_en_reg_2 ;
                    next_ctx_en_reg_4 <= next_ctx_en_reg_3 ;
                end
            endcase
        end
    end
    
    always @(posedge iClk or negedge iRst) begin
        if (~iRst) begin
            Ctx_addr <= 0;
        end
        else begin
            if (current_state == LOAD_CTX) begin
                Ctx_addr <= Ctx_addr + 1;
            end
            else if (done_wire) begin
                Ctx_addr <= 0;
            end
            else begin
                Ctx_addr <= Ctx_addr;
            end
        end
    end
    
    assign oCtx_addr      = Ctx_addr;
    assign oCtx_en        = (current_state == LOAD_CTX);
    assign oCtx_write_en  = 1'b0; 
    assign oWeight_addr     = Weight_addr_offset + Weight_addr_start;
    assign oWeight_en       = (current_state == EXECUTE) && conv_en;
    assign oWeight_write_en = 1'b0;
    assign oBias_addr       = Bias_addr;
    assign oBias_en         = (current_state == EXECUTE) && (j_reg == J) && (k_reg == K) && conv_en;
    assign oBias_write_en   = 1'b0;
    assign oScale_addr      = Scale_addr;
    assign oScale_en        = (current_state == EXECUTE) && (j_reg == J) && (k_reg == K) && conv_en;
    assign oScale_write_en  = 1'b0;
    assign LDM_addr_a       = LDM_addr + LDM_addr_cnt_y;
    assign oLDM_addr_a      = {Source_LDM,LDM_addr_a};
    assign oLDM_en_a        = (current_state == EXECUTE) ? 1'b1 : 1'b0;
    assign oCTRL_LDM_write_en_a  = 1'b0;
    assign LDM_addr_b       = LDM_addr + LDM_addr_cnt_y + 1;
    assign oLDM_addr_b      = {Source_LDM,LDM_addr_b};
    assign oLDM_en_b        = (current_state == EXECUTE) ? 1'b1: 1'b0;
    assign oCTRL_LDM_write_en_b  = 1'b0;
    
    assign oALU_LDM_addr_store = {Destination_LDM,Start_LDM};
    assign oMux_select = MUX_select;
    assign oLayer_done      = layer_done_wire;
    assign oDone            = done_wire;
    assign oCfg             = cfg;
    assign oReLU_en         = ReLU_en;
    assign oPU_mode = (cfg == MP) ? 1'b1 : 1'b0;
    assign oPadding_en = (current_state == LOAD_CTX) ? 0 : Padding_en_reg;
    assign oIncrement_addr_en = CTRL_LDM_Incr_reg;
    assign oStride = stride;
    assign oPU_en = (current_state == EXECUTE) ? 1 : 0;
    
    
    always @(*) begin
        case (Padding_select)
            4'd0: Padding_en_reg = 10'b0000000001;
            4'd1: Padding_en_reg = 10'b0000000011;
            4'd2: Padding_en_reg = 10'b0000000111;
            4'd7: Padding_en_reg = 10'b1110000000;
            4'd8: Padding_en_reg = 10'b1100000000;
            4'd9: Padding_en_reg = 10'b1000000000;
            default: Padding_en_reg = 10'b0000000000;
        endcase
    end
endmodule
