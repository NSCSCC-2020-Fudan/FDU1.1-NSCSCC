`ifndef __FETCH_SVH
`define __FETCH_SVH

typedef struct packed {
    word_t pcplus4;
    logic exception_instr;
} fetch_data_t;

`endif
