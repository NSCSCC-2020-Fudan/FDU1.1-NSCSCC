`include "mips.svh"

module srcaemux (
    input word_t e, m, w,
    input forward_t sel,
    output word_t srca
);
    always_comb begin
        case (sel)
            M:srca = m;
            W:srca = w;
            ORI:srca = e;
            default:srca = '0;
        endcase
    end
endmodule