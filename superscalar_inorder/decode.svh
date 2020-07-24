`ifndef __DECODE_SVH
`define __DECODE_SVH

typedef logic[5:0] op_t;
typedef logic[5:0] func_t;
typedef logic[4:0] shamt_t;

typedef enum logic[3:0] {
    ALU_ADDU, ALU_AND, ALU_OR, ALU_ADD, ALU_SLL, ALU_SRL, ALU_SRA, ALU_SUB, ALU_SLT, ALU_NOR, ALU_XOR, 
    ALU_SUBU, ALU_SLTU, ALU_PASSA, ALU_LUI, ALU_PASSB
} alufunc_t;

// op
`define OP_RT           6'b000000
`define OP_ADDI         6'b001000
`define OP_ADDIU        6'b001001
`define OP_SLTI         6'b001010
`define OP_SLTIU        6'b001011
`define OP_ANDI         6'b001100
`define OP_LUI          6'b001111
`define OP_ORI          6'b001101
`define OP_XORI         6'b001110
`define OP_BEQ          6'b000100
`define OP_BNE          6'b000101
`define OP_BGEZ         6'b000001
`define OP_BGTZ         6'b000111
`define OP_BLEZ         6'b000110
// `define OP_BLTZ         6'b000001
// `define OP_BGEZAL       6'b000001
// `define OP_BLTZAL       6'b000001
`define OP_J            6'b000010
`define OP_JAL          6'b000011
`define OP_LB           6'b100000
`define OP_LBU          6'b100100
`define OP_LH           6'b100001
`define OP_LHU          6'b100101
`define OP_LW           6'b100011
`define OP_SB           6'b101000
`define OP_SH           6'b101001
`define OP_SW           6'b101011
`define OP_ERET         6'b010000
// `define OP_MFC0         6'b010000
// `define OP_MTC0         6'b010000


// funct
`define F_ADD           6'b100000
`define F_ADDU          6'b100001
`define F_SUB           6'b100010
`define F_SUBU          6'b100011
`define F_SLT           6'b101010
`define F_SLTU          6'b101011
`define F_DIV           6'b011010
`define F_DIVU          6'b011011
`define F_MULT          6'b011000
`define F_MULTU         6'b011001
`define F_AND           6'b100100
`define F_NOR           6'b100111
`define F_OR            6'b100101
`define F_XOR           6'b100110
`define F_SLLV          6'b000100
`define F_SLL           6'b000000
`define F_SRAV          6'b000111
`define F_SRA           6'b000011
`define F_SRLV          6'b000110
`define F_SRL           6'b000010
`define F_JR            6'b001000
`define F_JALR          6'b001001
`define F_MFHI          6'b010000
`define F_MFLO          6'b010010
`define F_MTHI          6'b010001
`define F_MTLO          6'b010011
`define F_BREAK         6'b001101
`define F_SYSCALL       6'b001100

`define B_BGEZ          5'b00001
`define B_BLTZ          5'b00000
`define B_BGEZAL        5'b10001
`define B_BLTZAL        5'b10000

`define C_ERET          5'b10000
`define C_MFC0          5'b00000
`define C_MTC0          5'b00100

typedef enum logic[1:0] { REGB, IMM} alusrcb_t;
typedef enum logic[2:0] { T_BEQ, T_BNE, T_BGEZ, T_BLTZ, T_BGTZ, T_BLEZ } branch_t;

typedef enum logic [5:0] { 
    // ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, 
    ADDU, RESERVED,
    BEQ, BNE, BGEZ, BGTZ, BLTZ, BLEZ, BGEZAL, BLTZAL, J, JAL, 
    LB, LBU, LH, LHU, LW, SB, SH, SW, ERET, MFC0, MTC0,
    ADD, SUB, SUBU, SLT, SLTU, DIV, DIVU, MULT, MULTU, 
    AND, NOR, OR, XOR, SLLV, SLL, SRAV, SRA, SRLV, SRL, 
    JR, JALR, MFHI, MFLO, MTHI, MTLO, BREAK, SYSCALL, LUI
} decoded_op_t;

`endif