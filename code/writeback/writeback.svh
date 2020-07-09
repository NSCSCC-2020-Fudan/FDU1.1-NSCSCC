`ifndef __WRITEBACK_SVH
`define __WRITEBACK_SVH

typedef struct packed {
    decoded_instr_t instr;
    creg_addr_t writereg;
    word_t result;
} wb_data_t;

`endif
