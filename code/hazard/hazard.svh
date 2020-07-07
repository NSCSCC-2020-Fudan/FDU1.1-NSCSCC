`ifndef __HAZARD_SVH
`define __HAZARD_SVH

typedef enum logic[1:0] { RD1 } forwardAD_t;
typedef enum logic[1:0] { RD2 } forwardBD_t;
typedef enum logic[1:0] { SRCA } forwardAE_t;
typedef enum logic[1:0] { SRCB } forwardBE_t;

interface hazard_intf();
    decoded_instr_t instrD, instrE, instrM;
    logic stallD, stallF, flushE, flushM, flushW;
    forwardAD_t forwardAD;
    forwardBD_t forwardBD;
    forwardAE_t forwardAE;
    forwardBE_t forwardBE;
    modport hazard_p(output stallD, stallF, flushE, flushM, flushW, forwardAD, forwardBD, forwardAE, forwardBE);
    modport fetch_p();
    modport decode_p();
    modport execute_p();
    modport memory_p();
    modport exception_p();
    modport Freg_p();
    modport Dreg_p();
    modport Ereg_p();
    modport Mreg_p();
    modport Wreg_p();
endinterface

`endif
