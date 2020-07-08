`include "mips.svh"

module srcbemux (
    input word_t srcb, imm, shamt,
    input decoded_instr_t instr,
    output word_t srcb
);

    always_comb begin
        if (instr.ctl.alusr) begin
            srcb = imm;
        end else if (instr.ctl.shift) begin
            case (op)
                LUI: srcb = 32'd16;
                SLL: srcb = shamt;
                SRL: srcb = shamt;
                SRA: srcb = shamt;
                default: begin
                    srcb = srcb0;
                end
            endcase
        end else begin
            srcb = srcb0;
        end
    end
endmodule