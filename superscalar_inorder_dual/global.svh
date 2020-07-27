`ifndef __GLOBAL_SVH
`define __GLOBAL_SVH

`include "mips.svh"

typedef logic[31:0] word_t;
typedef logic[4:0] creg_addr_t;
typedef logic[15:0] halfword_t;
typedef logic[31:0] m_addr_t;
typedef logic[7:0] byte_t;
typedef logic[63:0] dword_t;
// typedef logic[3:0] rwen_t; // 1 word has 4 bytes

typedef enum logic { ZERO_EXT, SIGN_EXT } ext_mode;

typedef struct packed {
    logic ren;
    logic [1: 0] size;
    m_addr_t addr;
} m_r_t;

typedef struct packed {
    logic wen;
    logic [1: 0] size;
    m_addr_t addr;
    word_t wd;
} m_w_t;

typedef struct packed {
    logic en, wt;
    logic [1: 0] size;
    m_addr_t addr;
    word_t wd, rd;
} m_q_t;

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
    logic en;
} fetch_data_t;

typedef struct packed {
    decoded_instr_t instr;
    // word_t rd;
    word_t aluout;
    creg_addr_t writereg;
    word_t hi, lo;
    word_t pcplus4;
} mem_data_t;

typedef struct packed {
    decoded_instr_t instr;
    creg_addr_t writereg;
    word_t result;
    word_t hi, lo;
} wb_data_t;

typedef enum logic[2:0] { NOFORWARD, RESULTW, ALUOUTM, HIM, LOM, HIW, LOW, ALUSRCAE } forward_t;

typedef struct packed {
    alufunc_t alufunc;
    logic memtoreg, memwrite;
    logic regwrite;
    alusrcb_t alusrc;
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

typedef struct packed {
    // creg_addr_t rs, rt, rd;
    decoded_op_t op;
    word_t extended_imm;
    word_t pcjump, pcbranch;
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
        word_t pcplus4, pcbranch;
        logic exception_instr, exception_ri;
        logic taken;
        word_t srca, srcb;
        creg_addr_t destreg;
        word_t result, resulthi, resultlo;
        logic in_delay_slot;
    } issue_data_t;
    
    typedef struct packed {
        decoded_instr_t instr;
        word_t pcplus4, pcbranch;
        logic exception_instr, exception_ri;
        logic taken;
        word_t srca, srcb;
        creg_addr_t destreg;
        word_t result, resulthi, resultlo;
        logic in_delay_slot;
    } exec_data_t;
    
    typedef struct packed{
        creg_addr_t [1: 0] destregE;
        word_t [1: 0] regdataE;
        logic [1: 0] lowriteE, hiwriteE;
        word_t [1: 0] hidataE, lodataE;
    } bypass_upd_t;
    
    typedef struct packed{
        logic branch, jump, jr;
        word_t pcbranch, pcjump, pcjr; 
    } pc_data_t;    logic taken;
    logic exception_instr, exception_ri;
    creg_addr_t srcrega, srcregb, destreg;
    word_t srca, srcb;
    logic in_delay_slot;
} decode_data_t;

typedef struct packed {
    decoded_instr_t instr;
    word_t pcplus4, pcbranch;
    logic exception_instr, exception_ri;
    logic taken;
    word_t srca, srcb;
    creg_addr_t destreg;
    word_t result, resulthi, resultlo;
    logic in_delay_slot;
} issue_data_t;

typedef struct packed {
    decoded_instr_t instr;
    word_t pcplus4, pcbranch;
    logic exception_instr, exception_ri;
    logic taken;
    word_t srca, srcb;
    creg_addr_t destreg;
    word_t result, resulthi, resultlo;
    logic in_delay_slot;
} exec_data_t;

typedef struct packed{
    creg_addr_t [1: 0] destregE;
    word_t [1: 0] regdataE;
    logic [1: 0] lowriteE, hiwriteE;
    word_t [1: 0] hidataE, lodataE;
} bypass_upd_t;

typedef struct packed{
    logic branch, jump, jr;
    word_t pcbranch, pcjump, pcjr; 
} pc_data_t;

`endif
