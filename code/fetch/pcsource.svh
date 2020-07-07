`ifndef __PCSOURCE_SVH
`define __PCSOURCE_SVH

`include "global.svh"

// typedef struct packed {
//     word_t pcexception;
//     word_t pcbranchD;
//     word_t pcjrD;
//     word_t pcjumpD;
//     word_t pcplus4F;
// } pcsource_t;

// typedef struct packed {
//     logic exception;
//     logic branch;
//     logic jr;
//     logic jump;
// } pc_signal_t;

interface Pcselect_intf(input word_t pcexception, input logic exception);
    word_t pcbranchD, pcjrD, pcjumpD, pcplus4F;
    logic branch_taken, jr, jump;
    modport select(input pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F);
    modport decode(output pcbranchD, pcjrD, pcjumpD);
    modport fetch(output pcplus4F);
endinterface

`endif
