`ifndef __HILO_SVH
`define __HILO_SVH

typedef struct packed {
    logic en_h, en_l;
    word_t wd_h, wd_l;
} w_hilo_t;

`endif
