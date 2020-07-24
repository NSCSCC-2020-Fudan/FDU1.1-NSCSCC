`include "mips.svh"

module DIVU ( 
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
                    DIVU: begin
                        ans = '0;
                        lo = {1'b0, a} / {1'b0, b};
                        hi = {1'b0, a} % {1'b0, b};
                    end
                    DIV: begin
                        ans = '0;
                        lo = signed'(a) / signed'(b);
                        hi = signed'(a) % signed'(b);
                    end
                    default: begin
                        hi = '0;
                        lo = '0;
                        ans = '0;
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