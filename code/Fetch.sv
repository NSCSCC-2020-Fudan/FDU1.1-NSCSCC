`include "mips.svh"

module Fetch (
    Freg.out in,
    Dreg.in out
);
    // assign out.pcplus4 = in.pc + 32'b4;
    adder#(32) pcadder(in.pc, 32'b100, out.pcplus4);
    
endmodule

module pcselect (
    input pcsource_t srcs,
    input pc_signal_t s,
    output word_t pcnext
);
    assign pcnext = s[3] ? srcs.pcexception : (
                    s[2] ? srcs.pcbranchD   : (
                    s[1] ? srcs.pcjrD       : (
                    s[0] ? srcs.pcjumpD     : 
                           srcs.pcplus4F)));
endmodule