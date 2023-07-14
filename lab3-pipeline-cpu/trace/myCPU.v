`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
    output wire [13:0]  inst_addr,
    input  wire [31:0]  inst,

    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_wen,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

// TODO: 完成你自己的单周期CPU设计
//

// TODO: 数据冒险
// TODO: 控制冒险

wire [31:0] pc;
wire [31:0] npc_npc;
wire [31:0] npc_pc4;
wire [31:0] sext_ext;

wire [31:0] alu_b;
wire [31:0] alu_c;
wire        alu_comp;

wire [31:0] rf_rD1;
wire [31:0] rf_rD2;
wire [31:0] rf_wD;

wire [1:0] npc_op;
wire       rf_we;
wire [1:0] rf_wsel;
wire [2:0] sext_op;
wire [3:0] alu_op;
wire       alu_bsel;
wire       dram_we;

wire [31:0] if_inst;
wire [31:0] if_pc4;
wire [31:0] id_inst;
wire [31:0] id_pc4;
wire [31:0] id_ext;
wire [31:0] id_rD1;
wire [31:0] id_rD2;
wire [ 1:0] id_npc_op;
wire [ 2:0] id_sext_op;
wire        id_ram_we;
wire [ 3:0] id_alu_op;
wire        id_alu_bsel;
wire        id_rf_rf1;
wire        id_rf_rf2;
wire        id_rf_we;
wire [ 1:0] id_rf_wsel;
wire [ 4:0] id_rR1;
wire [ 4:0] id_rR2;
wire [ 4:0] id_wR;
wire [31:0] ex_b;
wire [31:0] ex_c;
wire        ex_comp;
wire [31:0] ex_ext;
wire [31:0] ex_pc4;
wire [31:0] ex_rD1;
wire [31:0] ex_rD2;
wire [ 1:0] ex_npc_op;
wire        ex_ram_we;
wire [ 3:0] ex_alu_op;
wire        ex_alu_bsel;
wire        ex_rf_we;
wire [ 1:0] ex_rf_wsel;
wire [ 4:0] ex_wR;
wire [31:0] mem_c;
wire [31:0] mem_ext;
wire [31:0] mem_pc4;
wire [31:0] mem_rD2;
wire        mem_ram_we;
wire        mem_rf_we;
wire [ 1:0] mem_rf_wsel;
wire [ 4:0] mem_wR;
wire [31:0] if_c;
wire        if_comp;
wire [31:0] if_ext;
wire [ 1:0] if_npc_op;
wire [31:0] wb_c;
wire [31:0] wb_ext;
wire [31:0] wb_pc4;
wire [31:0] wb_rdo;
wire [31:0] wb_wD;
wire        wb_rf_we;
wire [ 1:0] wb_rf_wsel;
wire [ 4:0] wb_wR;

assign if_inst = inst;
assign id_rR1 = id_inst[19:15];
assign id_rR2 = id_inst[24:20];
assign id_wR = id_inst[11:7];
assign inst_addr = pc[15:2];
assign Bus_wen = mem_ram_we;
assign Bus_wdata = mem_rD2;
assign Bus_addr = mem_c;
assign mem_rdo = Bus_rdata;


NPC U_NPC(
    // input
    .pc     (pc),
    .offset (if_ext),
    .br     (if_comp),
    .next   (if_c),
    .op     (if_npc_op),
    // output
    .npc    (npc_npc),
    .pc4    (if_pc4)
);

PC U_PC(
    // input
    .rst    (cpu_rst),
    .clk    (cpu_clk),
    .din    (npc_npc),
    // output
    .pc     (pc)
);

SEXT U_SEXT (
    // input
    .op     (id_sext_op),
    .din    (id_inst[31:7]),
    // output
    .ext    (id_ext)
);

ALU U_ALU(
    // input
    .a      (ex_rD1),
    .b      (ex_b),
    .op     (ex_alu_op),
    // output
    .c      (ex_c),
    .comp   (ex_comp)
);

Controller U_Controller(
    // input
    .opcode     (id_inst[6:0]),
    .funct3     (id_inst[14:12]),
    .funct7     (id_inst[31:25]),
    // output
    .npc_op     (id_npc_op),
    .rf_we      (id_rf_we),
    .rf_wsel    (id_rf_wsel),
    .sext_op    (id_sext_op),
    .alu_op     (id_alu_op),
    .alu_bsel   (id_alu_bsel),
    .dram_we    (id_ram_we),
    .rf_rf1     (id_rf_rf1),
    .rf_rf2     (id_rf_rf2)
);

RF U_RF(
    // input
    .rst    (cpu_rst),
    .clk    (cpu_clk),
    .rR1    (id_rR1),
    .rR2    (id_rR2),
    .wR     (wb_wR),
    .we     (wb_we),
    .wD     (wb_wD),
    // output
    .rD1    (id_rD1),
    .rD2    (id_rD2)
);

MUX U_MUX (
    // input
    .rf_wsel        (wb_rf_wsel),
    .rf_wD_npc_pc4  (wb_pc4),
    .rf_wD_sext_ext (wb_ext),
    .rf_wD_alu_c    (wb_c),
    .rf_wD_dram_rdo (wb_rdo),
    .alu_bsel       (ex_alu_bsel),
    .alu_b_rf_rD2   (ex_rD2),
    .alu_b_sext_ext (ex_ext),
    // output
    .rf_wD          (wb_wD),
    .alu_b          (ex_b)
);

IF_ID U_IF_ID (
    .clk        (cpu_clk),
    .rst        (cpu_rst),
    .if_inst    (if_inst),
    .if_pc4     (if_pc4),
    .id_inst    (id_inst),
    .id_pc4     (id_pc4)
);

ID_EX U_ID_EX (
    .clk        (cpu_clk),
    .rst        (cpu_rst),
    .id_ext     (id_ext),
    .id_pc4     (id_pc4),
    .id_rD1     (id_rD1),
    .id_rD2     (id_rD2),
    .id_npc_op  (id_npc_op),
    .id_ram_we  (id_ram_we),
    .id_alu_op  (id_alu_op),
    .id_alu_bsel(id_alu_bsel),
    .id_rf_we   (id_rf_we),
    .id_rf_wsel (id_rf_wsel),
    .id_wR      (id_wR),
    .ex_ext     (ex_ext),
    .ex_pc4     (ex_pc4),
    .ex_rD1     (ex_rD1),
    .ex_rD2     (ex_rD2),
    .ex_npc_op  (ex_npc_op),
    .ex_ram_we  (ex_ram_we),
    .ex_alu_op  (ex_alu_op),
    .ex_alu_bsel(ex_alu_bsel),
    .ex_rf_we   (ex_rf_we),
    .ex_rf_wsel (ex_rf_wsel),
    .ex_wR      (ex_wR)
);

EX_MEM U_EX_MEM (
    .clk        (cpu_clk),
    .rst        (cpu_rst),
    .ex_c       (ex_c),
    .ex_comp    (ex_comp),
    .ex_ext     (ex_ext),
    .ex_pc4     (ex_pc4),
    .ex_rD2     (ex_rD2),
    .ex_npc_op  (ex_npc_op),
    .ex_ram_we  (ex_ram_we),
    .ex_rf_we   (ex_rf_we),
    .ex_rf_wsel (ex_rf_wsel),
    .ex_wR      (ex_wR),
    .mem_c      (mem_c),
    .mem_ext    (mem_ext),
    .mem_pc4    (mem_pc4),
    .mem_rD2    (mem_rD2),
    .mem_ram_we (mem_ram_we),
    .mem_rf_we  (mem_rf_we),
    .mem_rf_wsel(mem_rf_wsel),
    .mem_wR     (mem_wR),
    .if_c       (if_c),
    .if_comp    (if_comp),
    .if_ext     (if_ext),
    .if_npc_op  (if_npc_op)
);

MEM_WB U_MEM_WB (
    .clk        (cpu_clk),
    .rst        (cpu_rst),
    .mem_c      (mem_c),
    .mem_ext    (mem_ext),
    .mem_pc4    (mem_pc4),
    .mem_rdo    (mem_rdo),
    .mem_rf_we   (mem_rf_we),
    .mem_rf_wsel(mem_rf_wsel),
    .mem_wR     (mem_wR),
    .wb_c       (wb_c),
    .wb_ext     (wb_ext),
    .wb_pc4     (wb_pc4),
    .wb_rdo     (wb_rdo),
    .wb_rf_we   (wb_rf_we),
    .wb_rf_wsel (wb_rf_wsel),
    .wb_wR      (wb_wR)
);


reg [31:0] cnt;
always @(posedge cpu_clk or posedge cpu_rst) begin
  if (cpu_rst) cnt <= 32'd0;
  else cnt <= cnt + 32'd1;
end



`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = (cnt >= 5);
    assign debug_wb_pc        = wb_pc4 - 4;
    assign debug_wb_ena       = wb_rf_we;
    assign debug_wb_reg       = wb_wR;
    assign debug_wb_value     = wb_wD;
`endif

endmodule
