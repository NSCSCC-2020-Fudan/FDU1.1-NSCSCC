`ifndef __DECODE_SVH
`define __DECODE_SVH

`include "global.svh"
typedef logic[5:0] op_t;
typedef logic[5:0] func_t;
typedef logic[4:0] shamt_t;
// typedef logic[3:0] alufunc_t;
// typedef logic[2:0] aluop_t;


// // signed
// `define ALU_AND 4'b0000
// `define ALU_OR  4'b0001
// `define ALU_ADD 4'b0010
// `define ALU_SLL 4'b0011
// `define ALU_SRL 4'b0100
// `define ALU_SRA 4'b0101
// `define ALU_SUB 4'b0110
// `define ALU_SLT 4'b0111

// `define ALU_NOR  4'b1000
// `define ALU_XOR  4'b1001
// `define ALU_UADD 4'b1010
// // `define ALU_USLL 4'b1011
// // `define ALU_USRL 4'b1100
// // `define ALU_USRA 4'b1101
// `define ALU_USUB 4'b1110
// `define ALU_USLT 4'b1111

typedef enum logic[3:0] {
    AND, OR, ADD, SLL, SRL, SRA, SUB, SLT, NOR, XOR, 
    ADDU, SUBU, SLTU
} alufunc_t;

// // aluop
// `define ALUOP_ADD       4'b0000
// `define ALUOP_UADD      4'b0001
// `define ALUOP_RT        4'b0010
// `define ALUOP_SUB       4'b0011
// `define ALUOP_USUB      4'b0100
// `define ALUOP_SLT       4'b0101
// `define ALUOP_USLT      4'b0110
// `define ALUOP_AND       4'b0111
// `define ALUOP_SLL       4'b1000
// `define ALUOP_OR        4'b1001
// `define ALUOP_XOR       4'b1010

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
`define OP_BEQ          6'b000110
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
`define F_NOR           6'b100110
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

typedef enum logic { IMM, REG } alusrc_t;
typedef enum logic { RD, RT } regdst_t;
typedef struct packed {
    // logic memtoreg, memwrite;
    // logic branch, alusrc;
    // logic regdst, regwrite;
    // logic jump;
    // logic [3:0]aluop;
    alufunc_t alufunc;
    logic memread, memwrite;
    logic regwrite;
    alusrc_t alusrc;
    regdst_t regdst;
    logic branch;
    logic jump;
} control_t;

typedef enum logic [5:0] { 
    // ADDI, ADDIU, SLTI, SLTIU, ANDI, LUI, ORI, XORI, 
    BEQ, BNE, BGEZ, BGTZ, BLEZ, BLTZ, BGEZAL, BLTZAL, J, JAL, 
    LB, LBU, LH, LHU, LW, SB, SH, SW, ERET, MFC0, MTC0,
    ADD, ADDU, SUB, SUBU, SLT, SLTU, DIV, DIVU, MULT, MULTU, 
    AND, NOR, OR, XOR, SLLV, SLL, SRAV, SRA, SRLV, SRL, 
    JR, JALR, MFHI, MFLO, MTHI, MTLO, BREAK, SYSCALL
} decoded_op_t;

typedef struct packed {
    creg_addr_t rs, rt, rd;
    decoded_op_t op;
    word_t extended_imm;
    control_t ctl;
    shamt_t shamt;
} decoded_instr_t;

typedef struct packed {
    decoded_instr_t decoded_instr;
    word_t pcplus4;
    logic exception_instr, exception_ri;
    word_t srca, srcb;
} decode_data_t;

`endif