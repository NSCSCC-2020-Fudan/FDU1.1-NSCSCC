`ifndef __REGFILE_SVH
`define __REGFILE_SVH

`include "mips.svh"

typedef struct packed {
    logic wen;
    creg_addr_t addr;
    word_t wd;
} rf_w_t; // write regfile request

`endif