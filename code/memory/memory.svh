`ifndef __MEMORY_SVH
`define __MEMORY_SVH

`include "mips.svh"

typedef struct packed {
    decoded_instr_t decoded_instr;
    word_t rd, aluout;
    creg_addr_t writereg;
    word_t hi, lo;
    word_t pcplus4;
} mem_data_t;

`endif
