`include "interface.svh"
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
    for (genvar i = 0; i < ALU_NUM ; i++) begin
        assign wake.dst_commit[i].id = dataE.alu_commit[i].rob_addr;
        assign wake.dst_commit[i].valid = dataE.alu_commit[i].valid;
        assign wake.broadcast[i] = dataE.alu_commit[i].data;
    end
    for (genvar i = 0; i < MEM_NUM ; i++) begin
        assign wake.dst_commit[i + ALU_NUM].id = dataE.mem_commit[i].rob_addr;
        assign wake.dst_commit[i + ALU_NUM].valid = dataE.mem_commit[i].valid;
        assign wake.broadcast[i + ALU_NUM] = dataE.mem_commit[i].data;
    end
    for (genvar i = 0; i < BRU_NUM ; i++) begin
        assign wake.dst_commit[i + ALU_NUM + MEM_NUM].id = dataE.branch_commit[i].rob_addr;
        assign wake.dst_commit[i + ALU_NUM + MEM_NUM].valid = dataE.branch_commit[i].valid;
        assign wake.broadcast[ + ALU_NUM + MEM_NUMi] = dataE.branch_commit[i].data;
    end
    for (genvar i = 0; i < MULT_NUM ; i++) begin
        assign wake.dst_commit[i + ALU_NUM + MEM_NUM + BRU_NUM].id = dataE.mult_commit[i].rob_addr;
        assign wake.dst_commit[i + ALU_NUM + MEM_NUM + BRU_NUM].valid = dataE.mult_commit[i].valid;
        assign wake.broadcast[i + ALU_NUM + MEM_NUM + BRU_NUM] = dataE.mult_commit[i].data;
    end
endmodule