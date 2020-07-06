`include "MIPS.svh"

module TriMux #(
        parameter WIDTH = 32;
    )(
        input logic [WIDTH - 1: 0] a, b, c,
        input logic [1: 0] f,
        output logic [WIDTH - 1: 0] d
    );

    always @(*)
        case(f)
            2'b00: d = a;
            2'b01: d = b;
            2'b10: d = c;
            default: d = 32'b0;
        endcase

endmodule