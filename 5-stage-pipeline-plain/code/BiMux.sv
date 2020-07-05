`include "MIPS.h"

<<<<<<< HEAD
module BiMux #(
        parameter WIDTH = 32
    )(
        input logic [WIDTH - 1: 0] a, b,
        input logic f,
        output logic [WIDTH - 1: 0] c
    );

    assign c = (f) ? (a) : (b);
    
=======
module BiMux(input logic [31: 0]
    );

>>>>>>> f3e6f5489405c528c769f1ca9257a2f72d2ffca2
endmodule