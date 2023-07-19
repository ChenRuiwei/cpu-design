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
wire [31:0] pc;
wire [31:0] npc_npc;
wire [31:0] npc_pc4;
wire [31:0] rf_rD1;
wire [31:0] rf_rD2;
wire [31:0] rf_wD;
wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_c;
wire        alu_comp;
wire [31:0] sext_ext;
wire [31:0] ram_rdo;

wire [1:0] npc_op;
wire       rf_we;
wire [1:0] rf_wsel;
wire [2:0] sext_op;
wire [3:0] alu_op;
wire       alu_asel;
wire       alu_bsel;
wire       ram_we;
wire [2:0] ram_r_op;
wire [1:0] ram_w_op;

assign inst_addr = pc[15:2];
assign Bus_addr = alu_c;

NPC U_NPC(
    // input
    .pc     (pc),
    .offset (sext_ext),
    .br     (alu_comp),
    .next   (alu_c),
    .op     (npc_op),
    // output
    .npc    (npc_npc),
    .pc4    (npc_pc4)
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
    .op     (sext_op),
    .din    (inst[31:7]),
    // output
    .ext    (sext_ext)
);

ALU U_ALU(
    // input
    .a      (alu_a),
    .b      (alu_b),
    .op     (alu_op),
    // output
    .c      (alu_c),
    .comp   (alu_comp)
);

Controller U_Controller(
    // input
    .opcode     (inst[6:0]),
    .funct3     (inst[14:12]),
    .funct7     (inst[31:25]),
    // output
    .npc_op     (npc_op),
    .rf_we      (rf_we),
    .rf_wsel    (rf_wsel),
    .sext_op    (sext_op),
    .alu_op     (alu_op),
    .alu_asel   (alu_asel),
    .alu_bsel   (alu_bsel),
    .ram_we     (Bus_wen),
    .ram_r_op   (ram_r_op),
    .ram_w_op   (ram_w_op)
);

RF U_RF(
    // input
    .rst    (cpu_rst),
    .clk    (cpu_clk),
    .rR1    (inst[19:15]),
    .rR2    (inst[24:20]),
    .wR     (inst[11:7]),
    .we     (rf_we),
    .wD     (rf_wD),
    // output
    .rD1    (rf_rD1),
    .rD2    (rf_rD2)
);

RAM U_RAM(
    //input
    .Bus_rdata  (Bus_rdata),
    .Bus_addr   (alu_c),
    .wdin       (rf_rD2),
    .r_op       (ram_r_op),
    .w_op       (ram_w_op),
    // output
    .Bus_wdata  (Bus_wdata),
    .rdo        (ram_rdo)
);

MUX U_MUX (
    // input
    .rf_wsel        (rf_wsel),
    .rf_wD_npc_pc4  (npc_pc4),
    .rf_wD_sext_ext (sext_ext),
    .rf_wD_alu_c    (alu_c),
    .rf_wD_dram_rdo (ram_rdo),
    .alu_asel       (alu_asel),
    .alu_a_rf_rD1   (rf_rD1),
    .alu_a_pc_pc    (pc),
    .alu_bsel       (alu_bsel),
    .alu_b_rf_rD2   (rf_rD2),
    .alu_b_sext_ext (sext_ext),
    // output
    .rf_wD          (rf_wD),
    .alu_a          (alu_a),
    .alu_b          (alu_b)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc        = pc;
    assign debug_wb_ena       = rf_we;
    assign debug_wb_reg       = inst[11:7];
    assign debug_wb_value     = rf_wD;
`endif

endmodule
