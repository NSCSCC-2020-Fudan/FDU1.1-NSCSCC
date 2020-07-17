`include "mips.svh"

module srcbdmux (
    input word_t regfile, m, w, alusrcaE,
    input forward_t forward,
    output word_t srcb
);
    always_comb begin
        priority case (forward)
            ALUSRCAE: srcb = alusrcaE;
            ALUOUTM:srcb = m;
            RESULTW:srcb = w;
            NOFORWARD: begin
                srcb = regfile;
            end
            default: begin
                srcb = '0;
            end
        endcase
    end
endmodule