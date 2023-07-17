`include "defines.vh"

module HazardDetection (
    input  wire       clk,
    input  wire       rst,
    input  wire [6:0] id_opcode,
    input  wire [4:0] id_rR1,
    input  wire [4:0] id_rR2,
    input  wire       id_rf_rf1,
    input  wire       id_rf_rf2,
    input  wire [4:0] ex_wR,
    input  wire       ex_rf_we,
    input  wire [4:0] mem_wR,
    input  wire       mem_rf_we,
    input  wire [4:0] wb_wR,
    input  wire       wb_rf_we,
    output wire       control_hazard_update_pc,
    output wire       id_ex_hazard,
    output wire       id_mem_hazard,
    output wire       id_wb_hazard,
    output wire       id_control_hazard,
    output wire       if_id_pipeline_stop,
    output wire       id_ex_pipeline_stop,
    output wire       ex_mem_pipeline_stop,
    output wire       mem_wb_pipeline_stop
);

  wire rs1_id_ex_hazard;
  wire rs2_id_ex_hazard;
  wire rs1_id_mem_hazard;
  wire rs2_id_mem_hazard;
  wire rs1_id_wb_hazard;
  wire rs2_id_wb_hazard;
  reg [3:0] data_hazard_cycle_cnt;
  reg [3:0] control_hazard_cycle_cnt;

  assign rs1_id_ex_hazard = (ex_wR == id_rR1) && ex_rf_we && id_rf_rf1 && ex_wR;
  assign rs2_id_ex_hazard = (ex_wR == id_rR2) && ex_rf_we && id_rf_rf2 && ex_wR;
  assign rs1_id_mem_hazard = (mem_wR == id_rR1) && mem_rf_we && id_rf_rf1 && mem_wR;
  assign rs2_id_mem_hazard = (mem_wR == id_rR2) && mem_rf_we && id_rf_rf2 && mem_wR;
  assign rs1_id_wb_hazard = (wb_wR == id_rR1) && wb_rf_we && id_rf_rf1 && wb_wR;
  assign rs2_id_wb_hazard = (wb_wR == id_rR2) && wb_rf_we && id_rf_rf2 && wb_wR;

  assign id_ex_hazard = (rs1_id_ex_hazard || rs2_id_ex_hazard) && (data_hazard_cycle_cnt < 4'd3);
  assign id_mem_hazard = (rs1_id_mem_hazard || rs2_id_mem_hazard) && (data_hazard_cycle_cnt < 4'd2)
                            && (!id_ex_hazard);
  assign id_wb_hazard = (rs1_id_wb_hazard || rs2_id_wb_hazard) && (data_hazard_cycle_cnt < 4'd1)
                          && (!id_ex_hazard) && (!id_mem_hazard);
  assign id_control_hazard = ((id_opcode == `OP_B) || (id_opcode == `OP_JAL) || (id_opcode == `OP_JALR))
                                && (control_hazard_cycle_cnt < 4'd3) && (!id_ex_hazard) && (!id_mem_hazard) && (!id_wb_hazard);
  assign control_hazard_update_pc = control_hazard_cycle_cnt == 4'd2;

  always @(posedge clk or posedge rst) begin
    if (rst) data_hazard_cycle_cnt <= 4'd0;
    else if (id_ex_hazard || id_mem_hazard || id_wb_hazard)
      data_hazard_cycle_cnt <= data_hazard_cycle_cnt + 4'd1;
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

  assign if_id_pipeline_stop  = id_ex_hazard || id_mem_hazard || id_wb_hazard || id_control_hazard;
  assign id_ex_pipeline_stop  = id_ex_hazard || id_mem_hazard || id_wb_hazard;
  assign ex_mem_pipeline_stop = id_mem_hazard || id_wb_hazard;
  assign mem_wb_pipeline_stop = id_wb_hazard;

endmodule
