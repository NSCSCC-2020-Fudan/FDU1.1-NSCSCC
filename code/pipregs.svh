`ifndef __PIPREGS_SVH
`define __PIPREGS_SVH

`include "global.svh"

interface Freg(output word_t pc);
    modport in(output pc);
    modport out(input pc);
endinterface

interface Dreg(input word_t instr);
    word_t pcplus4;
    modport in(output pcplus4);
    modport out(input instr, pcplus4);
endinterface
    
interface Ereg();
    logic 
    modport in(output );
    modport out(input clk, reset, );
endinterface
`endif
