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
    output reg        alu_asel,
    output reg        alu_bsel,
    output reg        ram_we,
    output reg  [2:0] ram_r_op,
    output reg  [1:0] ram_w_op
);

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I, `OP_LD, `OP_S, `OP_LUI, `OP_AUIPC: npc_op = `NPC_PC4;
      `OP_JALR: npc_op = `NPC_NXT;
      `OP_JAL: npc_op = `NPC_JMP;
      `OP_B: npc_op = `NPC_BRA;
      default: npc_op = `NPC_PC4;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I, `OP_LD, `OP_JALR, `OP_LUI, `OP_JAL, `OP_AUIPC: rf_we = 1'b1;
      `OP_S, `OP_B: rf_we = 1'b0;
      default: rf_we = 1'b0;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_I, `OP_AUIPC: rf_wsel = `WB_ALU;
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
      `OP_LUI, `OP_AUIPC: sext_op = `EXT_U;
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
          3'b010:  alu_op = `ALU_SLT;
          3'b011:  alu_op = `ALU_SLTU;
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
          3'b010:  alu_op = `ALU_SLT;
          3'b011:  alu_op = `ALU_SLTU;
          default: alu_op = `ALU_ADD;
        endcase
      end
      `OP_LD, `OP_JALR, `OP_S, `OP_AUIPC: begin
        alu_op = `ALU_ADD;
      end
      `OP_B: begin
        case (funct3)
          3'b000:  alu_op = `ALU_EQ;
          3'b001:  alu_op = `ALU_NE;
          3'b100:  alu_op = `ALU_LT;
          3'b101:  alu_op = `ALU_GE;
          3'b110:  alu_op = `ALU_LTU;
          3'b111:  alu_op = `ALU_GEU;
          default: alu_op = `ALU_EQ;
        endcase
      end
      default: alu_op = `ALU_ADD;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_AUIPC: alu_asel = `ALU_A_PC;
      default:   alu_asel = `ALU_A_RS1;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_R, `OP_B: alu_bsel = `ALU_B_RS2;
      `OP_I, `OP_LD, `OP_JALR, `OP_S, `OP_AUIPC: alu_bsel = `ALU_B_EXT;
      default: alu_bsel = `ALU_B_RS2;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_S:   ram_we = 1'b1;
      default: ram_we = 1'b0;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_LD: begin
        case (funct3)
          3'b000:  ram_r_op = `RAM_R_B;
          3'b100:  ram_r_op = `RAM_R_BU;
          3'b001:  ram_r_op = `RAM_R_H;
          3'b101:  ram_r_op = `RAM_R_HU;
          3'b010:  ram_r_op = `RAM_R_W;
          default: ram_r_op = `RAM_R_W;
        endcase
      end
      default: ram_r_op = `RAM_R_W;
    endcase
  end

  always @(*) begin
    case (opcode)
      `OP_S: begin
        case (funct3)
          3'b000:  ram_w_op = `RAM_W_B;
          3'b001:  ram_w_op = `RAM_W_H;
          3'b010:  ram_w_op = `RAM_W_W;
          default: ram_w_op = `RAM_W_W;
        endcase
      end
      default: ram_w_op = `RAM_W_W;
    endcase
  end

endmodule
