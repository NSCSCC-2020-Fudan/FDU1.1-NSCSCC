`include "mips.svh"

module bpb_decode(
        input word_t instr,
        output logic jump, branch,
        output word_t pcjump
    );
    
    func_t func;
    assign func = instr[5:0];
    always_comb 
        begin
            jump = 1'b0;
            branch = 1'b0;
            case (func)
                `OP_J: jump = 1'b1;
                `OP_JAL: jump = 1'b1;
                `OP_BEQ: branch = 1'b1;
                `OP_BNE: branch = 1'b1;  
                `OP_BGEZ: branch = 1'b1;
                `OP_BLEZ: branch = 1'b1;
            endcase
        end
    
endmodule
