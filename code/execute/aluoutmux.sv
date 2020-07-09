`include "mips.svh"
module aluoutmux (
    input word_t aluout,
    input word_t pcplus8,
    input logic jump,
    output word_t out
);
    assign out = jump ? pcplus8 : aluout;
endmodule