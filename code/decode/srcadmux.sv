`include "mips.svh"

module srcadmux (
    input word_t regfile, m, w,
    input forward_t forward,
    // input srcad_source_t src,
    output word_t srca
);
    always_comb begin
        case (forward)
            ALUOUTM:srca = m;
            RESULTW:srca = w;
            NOFORWARD:srca = regfile;
            default:srca = '0;
        endcase
    end
endmodule