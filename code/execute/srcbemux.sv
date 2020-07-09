`include "mips.svh"

module srcbemux (
    input word_t wd, imm, shamt,
    input decoded_instr_t instr,
    output word_t alusrcb
);

    always_comb begin
        if (instr.ctl.alusrc == IMM) begin
            alusrcb = imm;
        end else if (instr.ctl.shift) begin
            case (instr.op)
                LUI: alusrcb = 32'd16;
                SLL: alusrcb = shamt;
                SRL: alusrcb = shamt;
                SRA: alusrcb = shamt;
                default: begin
                    alusrcb = wd;
                end
            endcase
        end else begin
            alusrcb = wd;
        end
    end
endmodule