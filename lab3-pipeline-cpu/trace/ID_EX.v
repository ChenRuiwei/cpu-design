module ID_EX (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] id_ext,
    input  wire [31:0] id_pc4,
    input  wire [31:0] id_rD1,
    input  wire [31:0] id_rD2,
    input  wire [ 1:0] id_npc_op,
    input  wire        id_ram_we,
    input  wire [ 3:0] id_alu_op,
    input  wire        id_alu_bsel,
    input  wire        id_rf_we,
    input  wire [ 1:0] id_rf_wsel,
    input  wire [ 4:0] id_wR,
    output reg  [31:0] ex_ext,
    output reg  [31:0] ex_pc4,
    output reg  [31:0] ex_rD1,
    output reg  [31:0] ex_rD2,
    output reg  [ 1:0] ex_npc_op,
    output reg         ex_ram_we,
    output reg  [ 3:0] ex_alu_op,
    output reg         ex_alu_bsel,
    output reg         ex_rf_we,
    output reg  [ 1:0] ex_rf_wsel,
    output reg  [ 4:0] ex_wR
);

  always @(posedge clk or posedge rst) begin
    if (rst) ex_ext <= 32'd0;
    else ex_ext <= id_ext;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_pc4 <= 32'd0;
    else ex_pc4 <= id_pc4;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rD1 <= 32'd0;
    else ex_rD1 <= id_rD1;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rD2 <= 32'd0;
    else ex_rD2 <= id_rD2;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_npc_op <= 2'd0;
    else ex_npc_op <= id_npc_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_ram_we <= 1'd0;
    else ex_ram_we <= id_ram_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_alu_op <= 4'd0;
    else ex_alu_op <= id_alu_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_alu_bsel <= 1'd0;
    else ex_alu_bsel <= id_alu_bsel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rf_we <= 1'd0;
    else ex_rf_we <= id_rf_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rf_wsel <= 2'd0;
    else ex_rf_wsel <= id_rf_wsel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_wR <= 5'd0;
    else ex_wR <= id_wR;
  end

endmodule
