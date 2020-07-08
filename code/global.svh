`ifndef __GLOBAL_SVH
`define __GLOBAL_SVH

typedef logic[31:0] word_t;
typedef logic[4:0] creg_addr_t;
typedef logic[15:0] halfword_t;
typedef logic[31:0] m_addr_t;
typedef logic[7:0] byte_t;
typedef logic[63:0] dword_t;
typedef logic[3:0] rwen_t; // 1 word has 4 bytes

typedef enum logic { ZERO_EXT, SIGN_EXT } ext_mode;

typedef struct packed {
    rwen_t ren;
    m_addr_t addr;
} m_r_t;

typedef struct packed {
    rwen_t wen;
    m_addr_t addr;
    word_t wd;
} m_w_t;
`endif
