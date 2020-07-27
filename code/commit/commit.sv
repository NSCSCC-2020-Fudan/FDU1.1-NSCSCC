module commit 
    import common::*;
    import commit_pkg::*;(
    ereg_intf.commit ereg,
    commit_intf.commit self,
    forward_intf.commit forward,
    wake_intf.commit wake,
    payloadRAM_intf.commit payloadRAM
);
    execute_data_t dataE;
    // ereg
    assign dataE = ereg.dataE;

    // commit
    assign self.alu_commit = dataE.alu_commit;
    assign self.mem_commit = dataE.mem_commit;
    assign self.branch_commit = dataE.branch_commit;
    assign self.mult_commit = dataE.mult_commit;

    // forward
    for (genvar i = 0; i < ALU_NUM ; i++) begin
        assign forward.dst[i] = dataE.alu_commit[i].dst;
        assign forward.data[i] = dataE.alu_commit[i].data;
    end
    // wake

    // payloadRAM
    
endmodule