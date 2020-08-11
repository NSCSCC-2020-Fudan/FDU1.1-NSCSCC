`include "mips.svh"

module pc_cmtselect(
        input logic clk, reset,
        input logic exception_valid, is_eret, branch, jump, jr, tlb_ex,
        input word_t pcexception, epc, pcbranch, pcjump, pcjr, pctlb,
        output word_t pc_new,
        output logic pc_upd
    );
    assign pc_upd = exception_valid | is_eret | branch | jr | jump;
    assign pc_new = exception_valid      ? pcexception : (
                    is_eret              ? epc         : (
                    tlb_ex               ? pctlb       : (
                    branch               ? pcbranch    : (
                    jr                   ? pcjr        : (
                    jump                 ? pcjump      : 
                                           32'hbfc00000)))));
                                               
endmodule