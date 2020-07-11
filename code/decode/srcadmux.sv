`include "mips.svh"

module srcadmux (
    input word_t regfile, m, w, 
    input word_t hiD, loD, cp0D, 
    input word_t alusrcaE,
    input forward_t forward,
    input control_t ctl,
    output word_t srca
);
    always_comb begin
        priority case (forward)
            ALUSRCAE:srca = alusrcaE;
            ALUOUTM:srca = m;
            RESULTW:srca = w;
            NOFORWARD: begin
                case (1'b1)
                    ctl.hitoreg: srca = hiD;
                    ctl.lotoreg: srca = loD;
                    ctl.cp0toreg: srca = cp0D;
                    default: begin
                        srca = regfile;
                    end
                endcase
            end
            default: begin
                srca = '0;
            end
        endcase
    end
endmodule