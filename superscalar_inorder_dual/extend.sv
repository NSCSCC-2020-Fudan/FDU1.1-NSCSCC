`include "mips.svh"

module extend (
        input halfword_t in,
        input logic s,
        output word_t out
    );
    assign out = s ? {16'b0, in} : {{16{in[15]}}, in};
endmodule