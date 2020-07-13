`ifndef __DIVIDER_SVH
`define __DIVIDER_SVH
`include "mips.svh"
typedef enum logic[2:0] { TWO_P, ONE_P, ZERO_P, ONE_N, TWO_N, WRONG_N } quotient_bit_t;

typedef struct packed{
    logic ok;
    logic [64:0] PA;
    word_t B;
    logic [4:0] shiftnum;
    logic [31:0] Q;
} divide_data_t;
`endif
