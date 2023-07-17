`include "defines.vh"

module NPC (
    input  wire [31:0] if_pc,
    input  wire        control_hazard_update_pc,
    input  wire        pipeline_stop,
    input  wire [31:0] pc,
    input  wire [31:0] offset,
    input  wire        br,
    input  wire [31:0] next,
    input  wire [ 1:0] op,
    output reg  [31:0] npc,
    output wire [31:0] pc4
);

  assign pc4 = pc + 32'd4;

  always @(*) begin
    if (control_hazard_update_pc) begin
      case (op)
        `NPC_PC4: npc = if_pc + 32'd4;
        `NPC_NXT: npc = next;
        `NPC_BRA: npc = br ? if_pc + offset : if_pc + 32'd4;
        `NPC_JMP: npc = if_pc + offset;
        default:  npc = if_pc + 32'd4;
      endcase
    end else if (pipeline_stop) begin
      npc = pc;
    end else begin
      case (op)
        `NPC_PC4: npc = pc + 32'd4;
        default:  npc = pc + 32'd4;
      endcase
    end
  end
endmodule
