`include "mips.svh"

module srcadmux (
    input word_t regfile, m, w, 
    input word_t hiD, loD, hiM, loM, hiW, loW,
    input word_t cp0D, 
    input forward_t forward,
    input control_t ctl,
    output word_t srca
);
    always_comb begin
        priority case (forward)
            ALUOUTM:srca = m;
            HIM:srca = hiM;
            LOM:srca = loM;
            RESULTW:srca = w;
            HIW:srca = hiW;
            LOW:srca = loW;
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