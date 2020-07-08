`ifndef __HILO_SVH
`define __HILO_SVH
`include "mips.svh"
typedef struct packed {
    logic wen_h, wen_l;
    word_t wd_h, wd_l;
} w_hilo_t;

`endif
