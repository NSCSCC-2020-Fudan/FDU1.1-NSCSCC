module pcselect 
    import common::*;(
    freg_intf.pcselect freg,
    pcselect_intf.pcselect ports
);
    word_t pc;
    logic exception_valid, branch_taken;
    word_t pcexception, pcbranch, pcplus4;
    assign pc = exception_valid ? pcexception : 
                (branch_taken ? pcbranch : pcplus4);

    assign ports.pc_new = pc;
    assign pcexception = ports.pcexception;
    assign pcbranch = ports.pcbranch;
    assign pcplus4 = ports.pcplus4;
endmodule