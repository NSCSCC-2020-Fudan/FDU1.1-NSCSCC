`ifndef __MEMORY_SVH
`define __MEMORY_SVH

typedef struct packed {
    decoded_instr_t decoded_instr;
    word_t readdata, aluout;
    word_t hi, lo;
} mem_data_t;

`endif
