`include "mips.svh"

module forwardaemux (
    input word_t e, m, w,
    input forward_t forward,
    output word_t srca
);
    always_comb begin
        case (forward)
            ALUOUTM:srca = m;
            RESULTW:srca = w;
            NOFORWARD:srca = e;
            default:srca = '0;
        endcase
    end
endmodule