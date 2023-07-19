`include "defines.vh"

module RAM (
    input  wire [31:0] Bus_rdata,
    input  wire [31:0] Bus_addr,
    input  wire [31:0] wdin,
    input  wire [ 2:0] r_op,
    input  wire [ 1:0] w_op,
    output reg  [31:0] Bus_wdata,
    output reg  [31:0] rdo
);

  wire [1:0] low_addr;
  assign low_addr = Bus_addr[1:0];

  always @(*) begin
    case (r_op)
      `RAM_R_B: begin
        case (low_addr)
          2'b00:   rdo = {{24{Bus_rdata[7]}}, Bus_rdata[7:0]};
          2'b01:   rdo = {{24{Bus_rdata[15]}}, Bus_rdata[15:8]};
          2'b10:   rdo = {{24{Bus_rdata[23]}}, Bus_rdata[23:16]};
          2'b11:   rdo = {{24{Bus_rdata[31]}}, Bus_rdata[31:24]};
          default: rdo = {{24{Bus_rdata[7]}}, Bus_rdata[7:0]};
        endcase
      end
      `RAM_R_BU: begin
        case (low_addr)
          2'b00:   rdo = {24'd0, Bus_rdata[7:0]};
          2'b01:   rdo = {24'd0, Bus_rdata[15:8]};
          2'b10:   rdo = {24'd0, Bus_rdata[23:16]};
          2'b11:   rdo = {24'd0, Bus_rdata[31:24]};
          default: rdo = {24'd0, Bus_rdata[7:0]};
        endcase
      end
      `RAM_R_H: begin
        case (low_addr[1])
          1'b0: rdo = {{16{Bus_rdata[15]}}, Bus_rdata[15:0]};
          1'b1: rdo = {{16{Bus_rdata[31]}}, Bus_rdata[31:16]};
          default: rdo = {{16{Bus_rdata[15]}}, Bus_rdata[15:0]};
        endcase
      end
      `RAM_R_HU: begin
        case (low_addr[1])
          1'b0: rdo = {16'd0, Bus_rdata[15:0]};
          1'b1: rdo = {16'd0, Bus_rdata[31:16]};
          default: rdo = {16'd0, Bus_rdata[15:0]};
        endcase
      end
      `RAM_R_W: rdo = Bus_rdata;
      default:  rdo = Bus_rdata;
    endcase
  end

  always @(*) begin
    case (w_op)
      `RAM_W_B: begin
        case (low_addr)
          2'b00:   Bus_wdata = {Bus_rdata[31:8], wdin[7:0]};
          2'b01:   Bus_wdata = {Bus_rdata[31:16], wdin[7:0], Bus_rdata[7:0]};
          2'b10:   Bus_wdata = {Bus_rdata[31:24], wdin[7:0], Bus_rdata[15:0]};
          2'b11:   Bus_wdata = {wdin[7:0], Bus_rdata[23:0]};
          default: Bus_wdata = {Bus_rdata[31:8], wdin[7:0]};
        endcase
      end
      `RAM_W_H: begin
        case (low_addr[1])
          1'b0: Bus_wdata = {Bus_rdata[31:16], wdin[15:0]};
          1'b1: Bus_wdata = {wdin[15:0], Bus_rdata[15:0]};
          default: Bus_wdata = {Bus_rdata[31:16], wdin[15:0]};
        endcase
      end
      `RAM_W_W: Bus_wdata = wdin;
      default:  Bus_wdata = wdin;
    endcase
  end

endmodule
