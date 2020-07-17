`ifndef __GLOBAL_SVH
`define __GLOBAL_SVH
`include "mips.svh"
typedef logic[31:0] word_t;
typedef logic[4:0] creg_addr_t;
typedef logic[15:0] halfword_t;
typedef logic[31:0] m_addr_t;
typedef logic[7:0] byte_t;
typedef logic[63:0] dword_t;
typedef logic[3:0] rwen_t; // 1 word has 4 bytes

typedef enum logic { ZERO_EXT, SIGN_EXT } ext_mode;

typedef struct packed {
    logic ren;
    m_addr_t addr;
    logic[1:0] size;
} m_r_t;

typedef struct packed {
    logic[1:0] size;
    logic wen;
    m_addr_t addr;
    word_t wd;
} m_w_t;

typedef struct packed {
    logic wen_h, wen_l;
    word_t wd_h, wd_l;
} hilo_w_t;

typedef struct packed {
    logic wen;
    creg_addr_t addr;
    word_t wd;
} rf_w_t; // write regfile request


typedef struct packed {
    word_t instr_;
    word_t pcplus4;
    logic exception_instr;
} fetch_data_t;

typedef logic[5:0] op_t;
typedef logic[5:0] func_t;
typedef logic[4:0] shamt_t;

typedef enum logic[3:0] {
    ALU_ADDU, ALU_AND, ALU_OR, ALU_ADD, ALU_SLL, ALU_SRL, ALU_SRA, ALU_SUB, ALU_SLT, ALU_NOR, ALU_XOR, 
    ALU_SUBU, ALU_SLTU, ALU_PASSA, ALU_LUI, ALU_PASSB
} alufunc_t;

typedef enum logic[1:0] { REGB, IMM} alusrcb_t;
typedef enum logic { RT, RD } regdst_t;
typedef enum logic[2:0] { T_BEQ, T_BNE, T_BGEZ, T_BLTZ, T_BGTZ, T_BLEZ } branch_t;
typedef struct packed {
    alufunc_t alufunc;
    logic memtoreg, memwrite;
    logic regwrite;
    alusrcb_t alusrc;
    regdst_t regdst;
    logic branch;
    logic branch1, branch2;
    branch_t branch_type;
    logic jump;
    logic jr;
    logic shamt_valid;
    logic zeroext;
    logic cp0write;
    logic is_eret;
    logic hiwrite;
    logic lowrite;
    logic is_bp;
    logic is_sys;
    logic hitoreg, lotoreg, cp0toreg;
} control_t;

typedef enum logic [5:0] { 
    // ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, 
    ADDU, RESERVED,
    BEQ, BNE, BGEZ, BGTZ, BLEZ, BLTZ, BGEZAL, BLTZAL, J, JAL, 
    LB, LBU, LH, LHU, LW, SB, SH, SW, ERET, MFC0, MTC0,
    ADD, SUB, SUBU, SLT, SLTU, DIV, DIVU, MULT, MULTU, 
    AND, NOR, OR, XOR, SLLV, SLL, SRAV, SRA, SRLV, SRL, 
    JR, JALR, MFHI, MFLO, MTHI, MTLO, BREAK, SYSCALL, LUI
} decoded_op_t;

typedef struct packed {
    creg_addr_t rs, rt, rd;
    decoded_op_t op;
    word_t extended_imm;
    control_t ctl;
    shamt_t shamt;
} decoded_instr_t;

typedef struct packed {
    decoded_instr_t instr;
    word_t pcplus4;
    logic exception_instr, exception_ri;
    word_t srca, srcb;
    logic in_delay_slot;
} decode_data_t;

typedef struct packed {
    decoded_instr_t instr;
    word_t rd;
    word_t aluout;
    creg_addr_t writereg;
    word_t hi, lo;
    word_t pcplus4;
} mem_data_t;

typedef struct packed {
    decoded_instr_t instr;
    logic exception_instr, exception_ri, exception_of;
    word_t aluout;
    creg_addr_t writereg;
    word_t writedata;
    word_t hi, lo;
    word_t pcplus4;
    logic in_delay_slot;
} exec_data_t;

typedef struct packed {
    decoded_instr_t instr;
    creg_addr_t writereg;
    word_t result;
    word_t hi, lo;
} wb_data_t;

typedef enum logic[2:0] { NOFORWARD, RESULTW, ALUOUTM, HIM, LOM, HIW, LOW, ALUSRCAE } forward_t;
`endif
