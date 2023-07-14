module LEDDriver (
    input  wire        rst,
    input  wire        clk,
    input  wire [11:0] addr,
    input  wire        wen,
    input  wire [31:0] wdata,
    output reg  [23:0] led
);

  always @(posedge clk or posedge rst) begin
    if (rst) led <= 24'd0;
    else if (wen) led <= wdata[23:0];
  end

endmodule
