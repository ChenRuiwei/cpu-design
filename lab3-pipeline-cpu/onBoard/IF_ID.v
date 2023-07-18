module IF_ID (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stop,
    input  wire        control_hazard,
    input  wire [31:0] if_inst,
    input  wire [31:0] if_pc,
    input  wire [31:0] if_pc4,
    output reg         id_have_inst,
    output reg  [31:0] id_inst,
    output reg  [31:0] id_pc,
    output reg  [31:0] id_pc4
);

  always @(posedge clk or posedge rst) begin
    if (rst) id_have_inst <= 1'd0;
    else if (control_hazard) id_have_inst <= 1'd0;
    else id_have_inst <= 1'd1;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) id_inst <= 32'd0;
    else if (pipeline_stop) id_inst <= id_inst;
    else id_inst <= if_inst;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) id_pc <= 32'd0;
    else if (pipeline_stop) id_pc <= id_pc;
    else id_pc <= if_pc;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) id_pc4 <= 32'd0;
    else if (pipeline_stop) id_pc4 <= id_pc4;
    else id_pc4 <= if_pc4;
  end

endmodule
