`include "defines.vh"

module HazardDetection (
    input  wire        clk,
    input  wire        rst,
    input  wire [ 6:0] id_opcode,
    input  wire [ 4:0] id_rR1,
    input  wire [ 4:0] id_rR2,
    input  wire        id_rf_rf1,
    input  wire        id_rf_rf2,
    input  wire [ 6:0] ex_opcode,
    input  wire [ 4:0] ex_wR,
    input  wire        ex_rf_we,
    input  wire [ 1:0] ex_rf_wsel,
    input  wire [31:0] ex_c,
    input  wire [31:0] ex_ext,
    input  wire [31:0] ex_pc4,
    input  wire [ 4:0] mem_wR,
    input  wire        mem_rf_we,
    input  wire [ 1:0] mem_rf_wsel,
    input  wire [31:0] mem_c,
    input  wire [31:0] mem_ext,
    input  wire [31:0] mem_pc4,
    input  wire [31:0] mem_rdo,
    input  wire [ 4:0] wb_wR,
    input  wire        wb_rf_we,
    input  wire [ 1:0] wb_rf_wsel,
    input  wire [31:0] wb_c,
    input  wire [31:0] wb_ext,
    input  wire [31:0] wb_pc4,
    input  wire [31:0] wb_rdo,
    output reg  [31:0] forward_rD1,
    output reg  [31:0] forward_rD2,
    output wire        rs1_id_data_hazard,
    output wire        rs2_id_data_hazard,
    output wire        control_hazard_update_pc,
    output wire        id_ex_hazard,
    output wire        id_mem_hazard,
    output wire        id_wb_hazard,
    output wire        id_control_hazard,
    output wire        if_id_pipeline_stop,
    output wire        id_ex_pipeline_stop,
    output wire        ex_mem_pipeline_stop,
    output wire        mem_wb_pipeline_stop
);

  wire rs1_id_ex_hazard;
  wire rs2_id_ex_hazard;
  wire rs1_id_mem_hazard;
  wire rs2_id_mem_hazard;
  wire rs1_id_wb_hazard;
  wire rs2_id_wb_hazard;
  wire id_ex_ld_hazard;
  reg [3:0] data_hazard_cycle_cnt;
  reg [3:0] control_hazard_cycle_cnt;
  reg start;

  always @(posedge clk or posedge rst) begin
    if (rst) start <= 1'd0;
    else start <= 1'd1;
  end

  assign rs1_id_ex_hazard = (ex_wR == id_rR1) && ex_rf_we && id_rf_rf1 && ex_wR;
  assign rs2_id_ex_hazard = (ex_wR == id_rR2) && ex_rf_we && id_rf_rf2 && ex_wR;
  assign rs1_id_mem_hazard = (mem_wR == id_rR1) && mem_rf_we && id_rf_rf1 && mem_wR;
  assign rs2_id_mem_hazard = (mem_wR == id_rR2) && mem_rf_we && id_rf_rf2 && mem_wR;
  assign rs1_id_wb_hazard = (wb_wR == id_rR1) && wb_rf_we && id_rf_rf1 && wb_wR;
  assign rs2_id_wb_hazard = (wb_wR == id_rR2) && wb_rf_we && id_rf_rf2 && wb_wR;

  assign rs1_id_data_hazard = rs1_id_ex_hazard || rs1_id_mem_hazard || rs1_id_wb_hazard;
  assign rs2_id_data_hazard = rs2_id_ex_hazard || rs2_id_mem_hazard || rs2_id_wb_hazard;

  assign id_ex_ld_hazard = (rs1_id_ex_hazard || rs2_id_ex_hazard) && (ex_opcode == `OP_LD) && (data_hazard_cycle_cnt < 4'd1);
  assign id_control_hazard = ((id_opcode == `OP_B) || (id_opcode == `OP_JAL) || (id_opcode == `OP_JALR))
                                && (control_hazard_cycle_cnt < 4'd3) && (!id_ex_ld_hazard) && (start);
  assign control_hazard_update_pc = control_hazard_cycle_cnt == 4'd2;

  assign id_ex_hazard = id_ex_ld_hazard;
  assign id_mem_hazard = 0;
  assign id_wb_hazard = 0;
  assign if_id_pipeline_stop = id_ex_hazard || id_mem_hazard || id_wb_hazard || id_control_hazard; // id_ex_ld_hazard || id_control_hazard
  assign id_ex_pipeline_stop = id_ex_hazard || id_mem_hazard || id_wb_hazard;  // id_ex_ld_hazard
  assign ex_mem_pipeline_stop = id_mem_hazard || id_wb_hazard;  // 0
  assign mem_wb_pipeline_stop = id_wb_hazard;  // 0

  always @(posedge clk or posedge rst) begin
    if (rst) data_hazard_cycle_cnt <= 4'd0;
    else if (id_ex_ld_hazard) data_hazard_cycle_cnt <= data_hazard_cycle_cnt + 4'd1;
    // to deal with the situation that data_hazard is followed by control_hazard
    // e.g. addi x1, 10; jal x14, 0(x1);
    // the jal command has both data_hazard and control_hazard
    else if (!id_control_hazard) data_hazard_cycle_cnt <= 4'd0;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) control_hazard_cycle_cnt <= 4'd0;
    else if (id_control_hazard) control_hazard_cycle_cnt <= control_hazard_cycle_cnt + 4'd1;
    else control_hazard_cycle_cnt <= 4'd0;
  end

  always @(*) begin
    if (rs1_id_ex_hazard && (ex_opcode != `OP_LD)) begin
      case (ex_rf_wsel)
        `WB_ALU: forward_rD1 = ex_c;
        `WB_PC4: forward_rD1 = ex_pc4;
        `WB_EXT: forward_rD1 = ex_ext;
        default: forward_rD1 = ex_c;
      endcase
    end else if (rs1_id_mem_hazard) begin
      case (mem_rf_wsel)
        `WB_ALU: forward_rD1 = mem_c;
        `WB_RAM: forward_rD1 = mem_rdo;
        `WB_PC4: forward_rD1 = mem_pc4;
        `WB_EXT: forward_rD1 = mem_ext;
        default: forward_rD1 = mem_c;
      endcase
    end else if (rs1_id_wb_hazard) begin
      case (wb_rf_wsel)
        `WB_ALU: forward_rD1 = wb_c;
        `WB_RAM: forward_rD1 = wb_rdo;
        `WB_PC4: forward_rD1 = wb_pc4;
        `WB_EXT: forward_rD1 = wb_ext;
        default: forward_rD1 = wb_c;
      endcase
    end else begin
      forward_rD1 = 32'd0;
    end
  end

  always @(*) begin
    if (rs2_id_ex_hazard && (ex_opcode != `OP_LD)) begin
      case (ex_rf_wsel)
        `WB_ALU: forward_rD2 = ex_c;
        `WB_PC4: forward_rD2 = ex_pc4;
        `WB_EXT: forward_rD2 = ex_ext;
        default: forward_rD2 = ex_c;
      endcase
    end else if (rs2_id_mem_hazard) begin
      case (mem_rf_wsel)
        `WB_ALU: forward_rD2 = mem_c;
        `WB_RAM: forward_rD2 = mem_rdo;
        `WB_PC4: forward_rD2 = mem_pc4;
        `WB_EXT: forward_rD2 = mem_ext;
        default: forward_rD2 = mem_c;
      endcase
    end else if (rs2_id_wb_hazard) begin
      case (wb_rf_wsel)
        `WB_ALU: forward_rD2 = wb_c;
        `WB_RAM: forward_rD2 = wb_rdo;
        `WB_PC4: forward_rD2 = wb_pc4;
        `WB_EXT: forward_rD2 = wb_ext;
        default: forward_rD2 = wb_c;
      endcase
    end else begin
      forward_rD2 = 32'd0;
    end
  end

endmodule
