`ifndef __PIPREGS_SVH
`define __PIPREGS_SVH

`include "global.svh"
`include "decode.svh"

interface Freg_intf(input logic clk, reset, output word_t pc);
    modport in(output pc);
    modport out(input pc);
endinterface

interface Dreg_intf(input word_t instr);
    word_t pcplus4;
    modport in(output pcplus4);
    modport out(input instr, pcplus4);
endinterface
    
interface Ereg_intf();
    word_t pcplus4;
    decoded_inst_t decoded_inst;
    modport in(output pcplus4, decoded_inst);
    modport out(input pcplus4, decoded_inst);
endinterface

interface Mreg_intf();
    
    modport in(output );
    modport out(input );
endinterface
`endif
