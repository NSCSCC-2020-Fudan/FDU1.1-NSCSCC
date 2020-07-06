`ifndef __PCSOURCE_SVH
`define __PCSOURCE_SVH

`include "global.svh"

typedef struct packed {
    word_t pcexception;
    word_t pcbranchD;
    word_t pcjrD;
    word_t pcjumpD;
    word_t pcplus4F;
} pcsource_t;

typedef struct packed {
    logic exception;
    logic branch;
    logic jr;
    logic jump;
} pc_signal_t;

`endif
