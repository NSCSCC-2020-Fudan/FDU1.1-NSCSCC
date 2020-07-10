`include "mips.svh"

module srcbdmux (
    input word_t regfile, m, w, 
    input word_t hiD, loD, hiM, loM, hiW, loW,
    input word_t cp0D, 
    input forward_t forward,
    input control_t ctl,
    output word_t srcb
);
    always_comb begin
        priority case (forward)
            ALUOUTM:srcb = m;
            HIM:srcb = hiM;
            LOM:srcb = loM;
            RESULTW:srcb = w;
            HIW:srcb = hiW;
            LOW:srcb = loW;
            NOFORWARD: begin
                case (1'b1)
                    ctl.hitoreg: srcb = hiD;
                    ctl.lotoreg: srcb = loD;
                    ctl.cp0toreg: srcb = cp0D;
                    default: begin
                        srcb = regfile;
                    end
                endcase
            end
            default: begin
                srcb = '0;
            end
        endcase
    end
endmodule