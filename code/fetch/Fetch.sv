`include "mips.svh"

module fetch (
    input word_t pc,
    output word_t pcplus4
);
    // assign out.pcplus4 = pc + 32'b4;
    adder#(32) pcadder(pc, 32'b100, pcplus4);
endmodule

module pcselect (
    input word_t pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F,
    input logic exception, branch_taken, jr, jump,
    output word_t pcnext
);
    assign pcnext = exception            ? pcexception : (
                    branch_taken         ? pcbranchD   : (
                    jr                   ? pcjrD       : (
                    jump                 ? pcjumpD     : 
                                           pcplus4F))) ;
endmodule

