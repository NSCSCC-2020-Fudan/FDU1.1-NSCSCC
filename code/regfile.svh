`ifndef __REGFILE_SVH
`define __REGFILE_SVH

`include "global.svh"
typedef struct packed {
    logic en;
    creg_addr_t addr;
    word_t wd;
} w_rf_r; // write regfile request

interface rf_intf(input logic clk, reset);
    creg_addr_t ra1, ra2;
    word_t src1, src2;
    w_rf_r w;
    modport rf(input clk, reset, ra1, ra2, w, output src1, src2);
    modport decode(input src1, src2, output ra1, ra2);
    modport writeback(output w);
endinterface

`endif