`include "mips.svh"

module JUDGE(
        input word_t srca, srcb,
        input branch_t branch_type,
        output logic taken 
    );
    
    always_comb begin
        case (branch_type)
            T_BEQ: taken = (srca == srcb);
            T_BNE: taken = (srca != srcb);
            T_BGEZ: taken = (~srca[31]);
            T_BLTZ: taken = (srca[31]);
            T_BGTZ: taken = (~srca[31] && srca != '0);
            T_BLEZ: taken = (srca[31] || srca == '0);
            default: taken = 1'b0;
        endcase
    end
/*    
    always_comb
        begin
            case (op)
                BEQ: taken = (srca == srcb);
                BNE: taken = (srca != srcb);
                BGEZ: taken = (~srca[31]);
                BLEZ: taken = (srca[31]);
                BGTZ: taken = (~srca[31] && srca != '0);
                BLTZ: taken = (srca[31] || srca == '0);
                BGEZAL: taken = (~srca[31]);
                BLTZAL: taken = (srca[31] || srca == '0);
                J: taken = 1'b1; 
                JAL: taken = 1'b1;
                JR: taken = 1'b1;
                JALR: taken = 1'b1; 
                default: taken = 1'b0;
            endcase
        end
*/        
endmodule