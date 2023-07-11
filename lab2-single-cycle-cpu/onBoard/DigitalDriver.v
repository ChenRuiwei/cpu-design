module DigitalDriver (
    input  wire        rst,
    input  wire        clk,
    input  wire [11:0] addr,
    input  wire        wen,
    input  wire [31:0] wdata,
    output reg  [ 7:0] dig_en,
    output wire        DN_A,
    output wire        DN_B,
    output wire        DN_C,
    output wire        DN_D,
    output wire        DN_E,
    output wire        DN_F,
    output wire        DN_G,
    output wire        DN_DP
);

  reg [ 7:0] led_n;  // 数码管的段信号
  reg [ 3:0] num;  // 每次读取data中一个4位2进制数，并使led_n产生相应输出
  reg [31:0] data;

  // 计数器，每2ms有cnt_end高电平
  localparam CNT_END = 32'd49999;
  reg [31:0] cnt;

  assign DN_A  = led_n[7];
  assign DN_B  = led_n[6];
  assign DN_C  = led_n[5];
  assign DN_D  = led_n[4];
  assign DN_E  = led_n[3];
  assign DN_F  = led_n[2];
  assign DN_G  = led_n[1];
  assign DN_DP = led_n[0];

  always @(posedge clk or posedge rst) begin
    if (rst) cnt <= 32'd0;
    else if (cnt == CNT_END) cnt <= 32'd0;
    else cnt <= cnt + 32'd1;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) dig_en <= 8'b11111110;
    else if (cnt == CNT_END) dig_en <= {dig_en[6:0], dig_en[7]};
  end

  always @(posedge clk or posedge rst) begin
    if (rst) data <= 32'd0;
    else if (wen) data <= wdata;
  end

  always @(*) begin
    case (dig_en)
      8'b11111110: num <= data[3:0];
      8'b11111101: num <= data[7:4];
      8'b11111011: num <= data[11:8];
      8'b11110111: num <= data[15:12];
      8'b11101111: num <= data[19:16];
      8'b11011111: num <= data[23:20];
      8'b10111111: num <= data[27:24];
      8'b01111111: num <= data[31:28];
      default: num <= 4'he;
    endcase
  end

  always @(*) begin
    case (num)
      4'h0: led_n = 8'b00000011;
      4'h1: led_n = 8'b10011111;
      4'h2: led_n = 8'b00100101;
      4'h3: led_n = 8'b00001101;
      4'h4: led_n = 8'b10011001;
      4'h5: led_n = 8'b01001001;
      4'h6: led_n = 8'b01000001;
      4'h7: led_n = 8'b00011111;
      4'h8: led_n = 8'b00000001;
      4'h9: led_n = 8'b00011001;
      4'ha: led_n = 8'b00010001;
      4'hb: led_n = 8'b11000001;
      4'hc: led_n = 8'b11100101;
      4'hd: led_n = 8'b10000101;
      4'he: led_n = 8'b01100001;
      4'hf: led_n = 8'b01110001;
      default: led_n = 8'b11111111;
    endcase
  end

endmodule
