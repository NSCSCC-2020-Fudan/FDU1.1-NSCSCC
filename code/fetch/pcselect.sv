module pcselect 
    import common::*;(
    freg_intf.pcselect freg,
    pcselect_intf.pcselect self
);
    word_t pc;
    logic exception_valid, branch_taken;
    word_t pcexception, pcbranch, pcplus4;
    assign pc = // exception_valid ? pcexception : 
                (branch_taken ? pcbranch : pcplus4);

    assign freg.pc_new = pc;
    assign pcexception = self.pcexception;
    assign pcbranch = self.pcbranch;
    assign pcplus4 = self.pcplus4;
    assign branch_taken = self.branch_taken;
endmodule