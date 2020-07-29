`include "mips.svh"

module pcselect (
        input logic exception_valid, is_eret, branch, jump, jr,
        input word_t pcexception, epc, pcbranch, pcjump, pcjr, pcplus,
        output word_t pc_new,
        output logic pc_upd
    );
    assign pc_upd = exception_valid | is_eret | branch | jr | jump;
    assign pc_new = exception_valid      ? pcexception : (
                    is_eret              ? epc         : (
                    branch               ? pcbranch   : (
                    jr                   ? pcjr       : (
                    jump                 ? pcjump     : 
                                           pcplus))));
                                               
endmodule