`include "mips.svh"

module srcaemux (
    input word_t e, m, w,
    input forward_t forward,
    output word_t alusrca
);
    always_comb begin
        case (forward)
            ALUOUTM:alusrca = m;
            RESULTW:alusrca = w;
            NOFORWARD:alusrca = e;
            default:alusrca = '0;
        endcase
    end
endmodule