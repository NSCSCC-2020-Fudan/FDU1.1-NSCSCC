`include "mips.svh"

module wdmux (
    input word_t e, m, w,
    input forward_t forward,
    output word_t wd
);
    always_comb begin
        case (forward)
            ALUOUTM:wd = m;
            RESULTW:wd = w;
            NOFORWARD:wd = e;
            default:wd = '0;
        endcase
    end
endmodule