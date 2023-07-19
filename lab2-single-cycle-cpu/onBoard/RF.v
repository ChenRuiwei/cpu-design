module RF (
    input  wire        rst,
    input  wire        clk,
    input  wire [ 4:0] rR1,
    input  wire [ 4:0] rR2,
    input  wire [ 4:0] wR,
    input  wire        we,
    input  wire [31:0] wD,
    output wire [31:0] rD1,
    output wire [31:0] rD2
);

  integer i;
  reg [31:0] rf[0:31];
  assign rD1 = rf[rR1];
  assign rD2 = rf[rR2];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1) begin
        rf[i] <= 32'd0;
      end
    end else if (we && (wR != 5'd0)) begin
      rf[wR] <= wD;
    end
  end

endmodule
