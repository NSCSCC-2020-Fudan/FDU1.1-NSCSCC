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
    logic in_delay_slot;
} fetch_data_t;

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
    cp0_cause_t cp0_cause;
    cp0_status_t cp0_status;
} exec_data_t;

typedef struct packed {
    decoded_instr_t instr;
    creg_addr_t writereg;
    word_t result;
    word_t hi, lo;
} wb_data_t;

typedef enum logic[2:0] { NOFORWARD, RESULTW, ALUOUTM, HIM, LOM, HIW, LOW, ALUSRCAE } forward_t;
`endif
