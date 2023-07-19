`include "defines.vh"

module ALU (
    input  wire signed [31:0] a,
    input  wire signed [31:0] b,
    input  wire        [ 3:0] op,
    output reg         [31:0] c,
    output reg                comp
);

  always @(*) begin
    case (op)
      `ALU_ADD:  c = a + b;
      `ALU_SUB:  c = a - b;
      `ALU_AND:  c = a & b;
      `ALU_OR:   c = a | b;
      `ALU_XOR:  c = a ^ b;
      `ALU_SLL:  c = a << b[4:0];
      `ALU_SRL:  c = a >> b[4:0];
      `ALU_SRA:  c = a >>> b[4:0];
      `ALU_SLT:  c = a < b;
      `ALU_SLTU: c = $unsigned(a) < $unsigned(b);
      default:   c = 32'd0;
    endcase
  end

  always @(*) begin
    case (op)
      `ALU_EQ:  comp = a == b;
      `ALU_NE:  comp = a != b;
      `ALU_LT:  comp = a < b;
      `ALU_GE:  comp = a >= b;
      `ALU_LTU: comp = $unsigned(a) < $unsigned(b);
      `ALU_GEU: comp = $unsigned(a) >= $unsigned(b);
      default:  comp = 1'b0;
    endcase
  end

endmodule
