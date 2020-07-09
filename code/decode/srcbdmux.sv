`include "mips.svh"

module srcbdmux (
    input word_t regfile, m, w,
    input forward_t forward,
    output word_t srcb
);
    always_comb begin
        case (forward)
            ALUOUTM:srcb = m;
            RESULTW:srcb = w;
            NOFORWARD:srcb = regfile;
            default:srcb = '0;
        endcase
    end
endmodule