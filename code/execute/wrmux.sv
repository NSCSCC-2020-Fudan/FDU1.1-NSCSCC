`include "mips.svh"
module wrmux (
    input creg_addr_t rt, rd,
    input logic jump,
    input regdst_t regdst,
    output creg_addr_t writereg
);
    localparam creg_addr_t ra = 5'b11111;
    assign writereg = (regdst == RD) ? rd : (jump ? ra : rt);
endmodule