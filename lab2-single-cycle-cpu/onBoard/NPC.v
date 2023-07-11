`include "defines.vh"

module NPC (
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
    case (op)
      `NPC_PC4: npc = pc + 32'd4;
      `NPC_NXT: npc = next;
      `NPC_BRA: npc = br ? pc + offset : pc + 32'd4;
      `NPC_JMP: npc = pc + offset;
      default:  npc = pc + 32'd4;
    endcase
  end
endmodule
