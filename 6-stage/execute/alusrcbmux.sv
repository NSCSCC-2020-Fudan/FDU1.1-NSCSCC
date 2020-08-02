`include "mips.svh"

module alusrcbmux (
    input word_t wd, imm,
    input alusrcb_t sel,
    output word_t alusrcb
);

    always_comb begin
        case (sel)
            REGB: alusrcb = wd;
            IMM: alusrcb = imm;
            default: begin
                alusrcb = wd;
            end
        endcase
    end
endmodule