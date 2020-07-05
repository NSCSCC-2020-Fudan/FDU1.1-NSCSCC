`include "MIPS.h"

module BiMux #(
        parameter WIDTH = 32
    )(
        input logic [WIDTH - 1: 0] a, b,
        input logic f,
        output logic [WIDTH - 1: 0] c
    );

    assign c = (f) ? (a) : (b);
    
endmodule