`ifndef __FETCH_SVH
`define __FETCH_SVH
`include "mips.svh"
typedef struct packed {
    word_t instr_;
    word_t pcplus4;
    logic exception_instr;
} fetch_data_t;

`endif
