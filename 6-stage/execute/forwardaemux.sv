`include "mips.svh"

module forwardaemux (
    input word_t e, m, w,
    input word_t hiM, loM, hiW, loW,
    input forward_t forward,
    output word_t srca
);
    always_comb begin
        case (forward)
            HIM:srca = hiM;
            LOM:srca = loM;
            ALUOUTM:srca = m;
            HIW:srca = hiW;
            LOW:srca = loW;
            RESULTW:srca = w;
            NOFORWARD:srca = e;
            default:srca = '0;
        endcase
    end
endmodule