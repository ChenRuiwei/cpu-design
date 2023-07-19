module EX_MEM (
    input  wire        clk,
    input  wire        rst,
    input  wire        pipeline_stop,
    input  wire        id_mem_hazard,
    input  wire        ex_have_inst,
    input  wire [31:0] ex_pc,
    input  wire [31:0] ex_c,
    input  wire        ex_comp,
    input  wire [31:0] ex_ext,
    input  wire [31:0] ex_pc4,
    input  wire [31:0] ex_rD2,
    input  wire [ 1:0] ex_npc_op,
    input  wire        ex_ram_we,
    input  wire [ 2:0] ex_ram_r_op,
    input  wire [ 1:0] ex_ram_w_op,
    input  wire        ex_rf_we,
    input  wire [ 1:0] ex_rf_wsel,
    input  wire [ 4:0] ex_wR,
    output reg         mem_have_inst,
    output reg  [31:0] mem_pc,
    output reg  [31:0] mem_c,
    output reg  [31:0] mem_ext,
    output reg  [31:0] mem_pc4,
    output reg  [31:0] mem_rD2,
    output reg         mem_ram_we,
    output reg  [ 2:0] mem_ram_r_op,
    output reg  [ 1:0] mem_ram_w_op,
    output reg         mem_rf_we,
    output reg  [ 1:0] mem_rf_wsel,
    output reg  [ 4:0] mem_wR,
    output reg  [31:0] if_pc,
    output reg  [31:0] if_c,
    output reg         if_comp,
    output reg  [31:0] if_ext,
    output reg  [ 1:0] if_npc_op
);

  always @(posedge clk or posedge rst) begin
    if (rst) mem_have_inst <= 1'd0;
    else if (id_mem_hazard) mem_have_inst <= 1'd0;
    else mem_have_inst <= ex_have_inst;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_c <= 32'd0;
    else if (pipeline_stop) mem_c <= mem_c;
    else mem_c <= ex_c;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_ext <= 32'd0;
    else if (pipeline_stop) mem_ext <= mem_ext;
    else mem_ext <= ex_ext;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_pc <= 32'd0;
    else if (pipeline_stop) mem_pc <= mem_pc;
    else mem_pc <= ex_pc;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_pc4 <= 32'd0;
    else if (pipeline_stop) mem_pc4 <= mem_pc4;
    else mem_pc4 <= ex_pc4;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_rD2 <= 32'd0;
    else if (pipeline_stop) mem_rD2 <= mem_rD2;
    else mem_rD2 <= ex_rD2;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_ram_we <= 1'd0;
    else if (pipeline_stop) mem_ram_we <= mem_ram_we;
    else mem_ram_we <= ex_ram_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_ram_r_op <= 3'd0;
    else if (pipeline_stop) mem_ram_r_op <= ex_ram_r_op;
    else mem_ram_r_op <= ex_ram_r_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_ram_w_op <= 2'd0;
    else if (pipeline_stop) mem_ram_w_op <= ex_ram_w_op;
    else mem_ram_w_op <= ex_ram_w_op;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_rf_we <= 1'd0;
    else if (pipeline_stop) mem_rf_we <= mem_rf_we;
    else mem_rf_we <= ex_rf_we;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_rf_wsel <= 2'd0;
    else if (pipeline_stop) mem_rf_wsel <= mem_rf_wsel;
    else mem_rf_wsel <= ex_rf_wsel;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) mem_wR <= 5'd0;
    else if (pipeline_stop) mem_wR <= mem_wR;
    else mem_wR <= ex_wR;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) if_pc <= 32'd0;
    else if (pipeline_stop) if_pc <= if_pc;
    else if_pc <= ex_pc;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) if_c <= 32'd0;
    else if (pipeline_stop) if_c <= if_c;
    else if_c <= ex_c;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) if_comp <= 1'd0;
    else if (pipeline_stop) if_comp <= if_comp;
    else if_comp <= ex_comp;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) if_ext <= 32'd0;
    else if (pipeline_stop) if_ext <= if_ext;
    else if_ext <= ex_ext;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) if_npc_op <= 2'd0;
    else if (pipeline_stop) if_npc_op <= if_npc_op;
    else if_npc_op <= ex_npc_op;
  end


endmodule
