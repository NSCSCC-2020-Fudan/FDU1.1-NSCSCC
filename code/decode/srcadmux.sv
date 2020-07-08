`include "mips.svh"

module srcadmux (
    input word_t regfile, m, w,
    input forward_t sel,
    output word_t srca
);
    always_comb begin
        case (sel)
            M:srca = m;
            W:srca = w;
            ORI:srca = regfile;
            default:srca = '0;
        endcase
    end
endmodule