`ifndef __HAZARD_SVH
`define __HAZARD_SVH

interface hazard_intf();
    decoded_instr_t instrD, instrE, instrM;
    logic stallD, stallF, flushE, flushM, flushW;
    modport hazard(output stallD, stallF, flushE, flushM, flushW);
    modport fetch();
    modport decode();
    modport execute();
    modport memory();
    modport exception();
    modport Freg();
    modport Dreg();
    modport Ereg();
    modport Mreg();
    modport Wreg();
endinterface

`endif
