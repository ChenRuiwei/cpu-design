`include "defines.vh"

module MUX (
    input wire [ 1:0] rf_wsel,
    input wire [31:0] rf_wD_npc_pc4,
    input wire [31:0] rf_wD_sext_ext,
    input wire [31:0] rf_wD_alu_c,
    input wire [31:0] rf_wD_dram_rdo,

    input wire        alu_asel,
    input wire [31:0] alu_a_rf_rD1,
    input wire [31:0] alu_a_pc_pc,

    input wire        alu_bsel,
    input wire [31:0] alu_b_rf_rD2,
    input wire [31:0] alu_b_sext_ext,

    output reg [31:0] rf_wD,
    output reg [31:0] alu_a,
    output reg [31:0] alu_b
);

  always @(*) begin
    case (rf_wsel)
      `WB_ALU: rf_wD = rf_wD_alu_c;
      `WB_RAM: rf_wD = rf_wD_dram_rdo;
      `WB_PC4: rf_wD = rf_wD_npc_pc4;
      `WB_EXT: rf_wD = rf_wD_sext_ext;
      default: rf_wD = 32'd0;
    endcase
  end

  always @(*) begin
    case (alu_asel)
      `ALU_A_RS1: alu_a = alu_a_rf_rD1;
      `ALU_A_PC: alu_a = alu_a_pc_pc;
      default: alu_a = 32'd0;
    endcase
  end

  always @(*) begin
    case (alu_bsel)
      `ALU_B_RS2: alu_b = alu_b_rf_rD2;
      `ALU_B_EXT: alu_b = alu_b_sext_ext;
      default: alu_b = 32'd0;
    endcase
  end

endmodule
