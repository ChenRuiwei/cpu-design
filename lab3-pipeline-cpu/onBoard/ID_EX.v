module ID_EX (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stop,
    input  wire        id_ex_hazard,
    input  wire        id_have_inst,
    input  wire [ 6:0] id_opcode,
    input  wire [31:0] id_ext,
    input  wire [31:0] id_pc,
    input  wire [31:0] id_pc4,
    input  wire [31:0] id_rD1,
    input  wire [31:0] id_rD2,
    input  wire [ 1:0] id_npc_op,
    input  wire        id_ram_we,
    input  wire [ 2:0] id_ram_r_op,
    input  wire [ 1:0] id_ram_w_op,
    input  wire [ 3:0] id_alu_op,
    input  wire        id_alu_asel,
    input  wire        id_alu_bsel,
    input  wire        id_rf_we,
    input  wire [ 1:0] id_rf_wsel,
    input  wire [ 4:0] id_wR,
    output reg         ex_have_inst,
    output reg  [ 6:0] ex_opcode,
    output reg  [31:0] ex_ext,
    output reg  [31:0] ex_pc,
    output reg  [31:0] ex_pc4,
    output reg  [31:0] ex_rD1,
    output reg  [31:0] ex_rD2,
    output reg  [ 1:0] ex_npc_op,
    output reg         ex_ram_we,
    output reg  [ 2:0] ex_ram_r_op,
    output reg  [ 1:0] ex_ram_w_op,
    output reg  [ 3:0] ex_alu_op,
    output reg         ex_alu_asel,
    output reg         ex_alu_bsel,
    output reg         ex_rf_we,
    output reg  [ 1:0] ex_rf_wsel,
    output reg  [ 4:0] ex_wR
);

  always @(posedge clk or posedge rst) begin
    if (rst) ex_have_inst <= 1'd0;
    else if (id_ex_hazard) ex_have_inst <= 1'd0;
    else ex_have_inst <= id_have_inst;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_opcode <= 7'd0;
    else if (pipeline_stop) ex_opcode <= ex_opcode;
    else ex_opcode <= id_opcode;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_ext <= 32'd0;
    else if (pipeline_stop) ex_ext <= ex_ext;
    else ex_ext <= id_ext;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_pc <= 32'd0;
    else if (pipeline_stop) ex_pc <= ex_pc;
    else ex_pc <= id_pc;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_pc4 <= 32'd0;
    else if (pipeline_stop) ex_pc4 <= ex_pc4;
    else ex_pc4 <= id_pc4;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rD1 <= 32'd0;
    else if (pipeline_stop) ex_rD1 <= ex_rD1;
    else ex_rD1 <= id_rD1;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rD2 <= 32'd0;
    else if (pipeline_stop) ex_rD2 <= ex_rD2;
    else ex_rD2 <= id_rD2;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_npc_op <= 2'd0;
    else if (pipeline_stop) ex_npc_op <= ex_npc_op;
    else ex_npc_op <= id_npc_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_ram_we <= 1'd0;
    else if (pipeline_stop) ex_ram_we <= ex_ram_we;
    else ex_ram_we <= id_ram_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_ram_r_op <= 3'd0;
    else if (pipeline_stop) ex_ram_r_op <= id_ram_r_op;
    else ex_ram_r_op <= id_ram_r_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_ram_w_op <= 2'd0;
    else if (pipeline_stop) ex_ram_w_op <= id_ram_w_op;
    else ex_ram_w_op <= id_ram_w_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_alu_op <= 4'd0;
    else if (pipeline_stop) ex_alu_op <= ex_alu_op;
    else ex_alu_op <= id_alu_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_alu_asel <= 1'd0;
    else if (pipeline_stop) ex_alu_asel <= ex_alu_asel;
    else ex_alu_asel <= id_alu_asel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_alu_bsel <= 1'd0;
    else if (pipeline_stop) ex_alu_bsel <= ex_alu_bsel;
    else ex_alu_bsel <= id_alu_bsel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rf_we <= 1'd0;
    else if (pipeline_stop) ex_rf_we <= ex_rf_we;
    else ex_rf_we <= id_rf_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_rf_wsel <= 2'd0;
    else if (pipeline_stop) ex_rf_wsel <= ex_rf_wsel;
    else ex_rf_wsel <= id_rf_wsel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) ex_wR <= 5'd0;
    else if (pipeline_stop) ex_wR <= ex_wR;
    else ex_wR <= id_wR;
  end

endmodule
