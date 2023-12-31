module MEM_WB (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stop,
    input  wire        id_wb_hazard,
    input  wire        mem_have_inst,
    input  wire [31:0] mem_c,
    input  wire [31:0] mem_ext,
    input  wire [31:0] mem_pc,
    input  wire [31:0] mem_pc4,
    input  wire [31:0] mem_rdo,
    input  wire        mem_rf_we,
    input  wire [ 1:0] mem_rf_wsel,
    input  wire [ 4:0] mem_wR,
    output reg         wb_have_inst,
    output reg  [31:0] wb_pc,
    output reg  [31:0] wb_c,
    output reg  [31:0] wb_ext,
    output reg  [31:0] wb_pc4,
    output reg  [31:0] wb_rdo,
    output reg         wb_rf_we,
    output reg  [ 1:0] wb_rf_wsel,
    output reg  [ 4:0] wb_wR
);

  always @(posedge clk or posedge rst) begin
    if (rst) wb_have_inst <= 1'd0;
    else if (id_wb_hazard) wb_have_inst <= 1'd0;
    else wb_have_inst <= mem_have_inst;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_pc <= 32'd0;
    else if (pipeline_stop) wb_pc <= wb_pc;
    else wb_pc <= mem_pc;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_c <= 32'd0;
    else if (pipeline_stop) wb_c <= wb_c;
    else wb_c <= mem_c;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_ext <= 32'd0;
    else if (pipeline_stop) wb_ext <= wb_ext;
    else wb_ext <= mem_ext;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_pc4 <= 32'd0;
    else if (pipeline_stop) wb_pc4 <= wb_pc4;
    else wb_pc4 <= mem_pc4;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_rdo <= 32'd0;
    else if (pipeline_stop) wb_rdo <= wb_rdo;
    else wb_rdo <= mem_rdo;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_rf_we <= 1'd0;
    else if (pipeline_stop) wb_rf_we <= wb_rf_we;
    else wb_rf_we <= mem_rf_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_rf_wsel <= 2'd0;
    else if (pipeline_stop) wb_rf_wsel <= wb_rf_wsel;
    else wb_rf_wsel <= mem_rf_wsel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) wb_wR <= 5'd0;
    else if (pipeline_stop) wb_wR <= wb_wR;
    else wb_wR <= mem_wR;
  end

endmodule
