`include "MIPS.svh"
module Extend #(
        parameter WIDTH = 16
    )(
        input logic [WIDTH - 1: 0] a,
        input logic Sign,
        output logic [31: 0] b
    );
    
    logic [31: 0] sig, unsig;
    assign sig = {(32 - WIDTh){a[WIDTH - 1]}, a};
    assign unsign = {(32 - WIDTH){1'b0}, a};
    BiMux(sig, unsig, Sign, b);
    
endmodule