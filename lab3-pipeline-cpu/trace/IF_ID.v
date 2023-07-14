module IF_ID (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] if_inst,
    input  wire [31:0] if_pc4,
    output reg  [31:0] id_inst,
    output reg  [31:0] id_pc4
);

  always @(posedge clk or posedge rst) begin
    if (rst) id_inst <= 32'd0;
    else id_inst <= if_inst;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) id_pc4 <= 32'd0;
    else id_pc4 <= if_pc4;
  end

endmodule
