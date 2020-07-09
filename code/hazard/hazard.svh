`ifndef __HAZARD_SVH
`define __HAZARD_SVH
`include "mips.svh"

// typedef enum logic[1:0] { W, M, ORI } forwardAD_t;
// typedef enum logic[1:0] { W, M, D } forwardBD_t;
// typedef enum logic[1:0] { W, M, E } forwardAE_t;
// typedef enum logic[1:0] { W, M, E } forwardBE_t;
typedef enum logic[1:0] { RESULTW, ALUOUTM, NOFORWARD } forward_t;
`endif
