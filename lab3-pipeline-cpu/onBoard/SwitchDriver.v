module SwitchDriver (
    input  wire        rst,
    input  wire        clk,
    input  wire [11:0] addr,
    input  wire [23:0] switch,
    output reg  [31:0] rdata
);

  always @(posedge clk or posedge rst) begin
    if (rst) rdata <= 32'd0;
    else rdata <= {8'd0, switch};
  end

endmodule
