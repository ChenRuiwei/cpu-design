module ButtonDriver (
    input  wire        rst,
    input  wire        clk,
    input  wire [11:0] addr,
    input  wire [ 4:0] button,
    output reg  [31:0] rdata
);

  always @(posedge clk or posedge rst) begin
    if (rst) rdata <= 32'd0;
    else rdata <= {27'd0, button};
  end

endmodule
