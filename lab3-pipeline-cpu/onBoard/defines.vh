// Annotate this macro before synthesis
// `define RUN_TRACE

// TODO: 在此处定义你的宏
// 
`define NPC_PC4 'b00
`define NPC_NXT 'b01
`define NPC_BRA 'b10
`define NPC_JMP 'b11

`define EXT_I 'b000
`define EXT_S 'b001
`define EXT_B 'b010
`define EXT_U 'b011
`define EXT_J 'b100

`define WB_ALU 'b00
`define WB_RAM 'b01
`define WB_PC4 'b10
`define WB_EXT 'b11

`define ALU_ADD 'b0000
`define ALU_SUB 'b0001
`define ALU_AND 'b0010
`define ALU_OR  'b0011
`define ALU_XOR 'b0100
`define ALU_SLL 'b0101
`define ALU_SRL 'b0110
`define ALU_SRA 'b0111
`define ALU_EQ  'b1000
`define ALU_NE  'b1001
`define ALU_LT  'b1010
`define ALU_GE  'b1011

`define ALU_B_RS2 'b0
`define ALU_B_EXT 'b1

`define OP_R    7'b0110011
`define OP_I    7'b0010011
`define OP_LD   7'b0000011
`define OP_JALR 7'b1100111
`define OP_S    7'b0100011
`define OP_B    7'b1100011
`define OP_LUI  7'b0110111
`define OP_JAL  7'b1101111


// 外设I/O接口电路的端口地址
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
