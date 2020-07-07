`ifndef __EXECUTE_SVH
`define __EXECUTE_SVH

`include "global.svh"

typedef struct packed {
    decoded_instr_t decoded_instr;
    logic exception_instr, exception_ri, exception_of;
    word_t aluout;
    creg_addr_t writereg;
    word_t writedata;
    word_t hi, lo;
} exec_data_t;

`endif
