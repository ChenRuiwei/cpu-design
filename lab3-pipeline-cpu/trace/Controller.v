`include "defines.vh"

module Controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [1:0] npc_op,
    output reg        rf_we,
    output reg  [1:0] rf_wsel,
    output reg  [2:0] sext_op,
    output reg  [3:0] alu_op,
    output reg        alu_bsel,
    output reg        dram_we,
    output reg        rf_rf1,    // read flag of rs1
    output reg        rf_rf2     // read flag of rs2
);

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I, `OP_LD, `OP_S, `OP_LUI: npc_op = `NPC_PC4;
      `OP_JALR: npc_op = `NPC_NXT;
      `OP_JAL: npc_op = `NPC_JMP;
      `OP_B: npc_op = `NPC_BRA;
      default: npc_op = `NPC_PC4;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I, `OP_LD, `OP_JALR, `OP_LUI, `OP_JAL: rf_we = 1'b1;
      `OP_S, `OP_B: rf_we = 1'b0;
      default: rf_we = 1'b0;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I: rf_wsel = `WB_ALU;
      `OP_LD: rf_wsel = `WB_RAM;
      `OP_JALR, `OP_JAL: rf_wsel = `WB_PC4;
      `OP_LUI: rf_wsel = `WB_EXT;
      default: rf_wsel = `WB_ALU;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_I, `OP_LD, `OP_JALR: sext_op = `EXT_I;
      `OP_S: sext_op = `EXT_S;
      `OP_B: sext_op = `EXT_B;
      `OP_LUI: sext_op = `EXT_U;
      `OP_JAL: sext_op = `EXT_J;
      default: sext_op = `EXT_I;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R: begin
        case (funct3)
          3'b000:  alu_op = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
          3'b111:  alu_op = `ALU_AND;
          3'b110:  alu_op = `ALU_OR;
          3'b100:  alu_op = `ALU_XOR;
          3'b001:  alu_op = `ALU_SLL;
          3'b101:  alu_op = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
          default: alu_op = `ALU_ADD;
        endcase
      end
      `OP_I: begin
        case (funct3)
          3'b000:  alu_op = `ALU_ADD;
          3'b111:  alu_op = `ALU_AND;
          3'b110:  alu_op = `ALU_OR;
          3'b100:  alu_op = `ALU_XOR;
          3'b001:  alu_op = `ALU_SLL;
          3'b101:  alu_op = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
          default: alu_op = `ALU_ADD;
        endcase
      end
      `OP_LD, `OP_JALR, `OP_S: begin
        alu_op = `ALU_ADD;
      end
      `OP_B: begin
        case (funct3)
          3'b000:  alu_op = `ALU_EQ;
          3'b001:  alu_op = `ALU_NE;
          3'b100:  alu_op = `ALU_LT;
          3'b101:  alu_op = `ALU_GE;
          default: alu_op = `ALU_EQ;
        endcase
      end
      default: alu_op = `ALU_ADD;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_B: alu_bsel = `ALU_B_RS2;
      `OP_I, `OP_LD, `OP_JALR, `OP_S: alu_bsel = `ALU_B_EXT;
      default: alu_bsel = `ALU_B_RS2;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_S:   dram_we = 1'b1;
      default: dram_we = 1'b0;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I, `OP_LD, `OP_JALR, `OP_S, `OP_B: rf_rf1 = 1'd1;
      `OP_LUI, `OP_JAL: rf_rf1 = 1'd0;
      default: rf_rf1 = 1'd0;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_S, `OP_B: rf_rf2 = 1'b1;
      `OP_I, `OP_LD, `OP_JALR, `OP_LUI, `OP_JAL: rf_rf2 = 1'b0;
      default: rf_rf2 = 1'b0;
    endcase
  end

endmodule
