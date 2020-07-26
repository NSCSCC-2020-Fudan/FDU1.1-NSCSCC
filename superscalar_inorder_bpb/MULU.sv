`include "mips.svh"

module MULU (
    input word_t a, b,
    input decoded_op_t op,
    input logic en,
    output word_t hi, lo,
    output logic finish
);
    dword_t ans;
    always_comb
        if (en)
            begin
                case (op)
                    MULTU: begin
                        ans = {32'b0, a} * {32'b0, b};
                        hi = ans[63:32];
                        lo = ans[31:0];
                    end
                    MULT: begin
                        ans = signed'({{32{a[31]}}, a}) * signed'({{32{b[31]}}, b});
                        hi = ans[63:32];
                        lo = ans[31:0];
                    end
                endcase
            end
        else
            begin
                hi = '0;
                lo = '0;
            end
    assign finish = 1'b1;            
endmodule