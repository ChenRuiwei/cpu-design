`include "defines.vh"

module SEXT (
    input  wire [ 2:0] op,
    input  wire [24:0] din,
    output reg  [31:0] ext
);

  always @(*) begin
    case (op)
      `EXT_I:  ext = {{20{din[24]}}, din[24:13]};
      `EXT_S:  ext = {{20{din[24]}}, din[24:18], din[4:0]};
      `EXT_B:  ext = {{20{din[24]}}, din[0], din[23:18], din[4:1], 1'b0};
      `EXT_U:  ext = {din[24:5], 12'd0};
      `EXT_J:  ext = {{12{din[24]}}, din[12:5], din[13], din[23:14], 1'b0};
      default: ext = 32'd0;
    endcase
  end

endmodule
