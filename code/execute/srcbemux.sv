`include "mips.svh"

module srcbemux (
    input word_t srcb0, imm, shamt,
    input decoded_instr_t instr,
    output word_t srcbE
);

    always_comb begin
        if (instr.ctl.alusrc) begin
            srcbE = imm;
        end else if (instr.ctl.shift) begin
            case (instr.op)
                LUI: srcbE = 32'd16;
                SLL: srcbE = shamt;
                SRL: srcbE = shamt;
                SRA: srcbE = shamt;
                default: begin
                    srcbE = srcb0;
                end
            endcase
        end else begin
            srcbE = srcb0;
        end
    end
endmodule