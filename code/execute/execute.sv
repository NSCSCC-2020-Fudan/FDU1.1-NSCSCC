`include "interface.svh"

module execute 
    import common::*;
    import execute_pkg::*;(
    input clk, resetn,
    ereg_intf.execute ereg,
    creg_intf.execute creg,
    forward_intf.execute forward,
    input logic d_data_ok,
    output mem_pkg::read_req_t mread,
    input word_t rd
);
    issue_pkg::issue_data_t dataI;
    execute_data_t dataE;
    // forward
    word_t [ALU_NUM-1:0]alusrca, alusrcb;
    word_t [MEM_NUM-1:0]agusrca, agusrcb;
    word_t [BRANCH_NUM-1:0]brusrca, brusrcb;
    word_t [MULT_NUM-1:0]multsrca, multsrcb;
    for (genvar i = 0; i < ALU_NUM ; i++) begin
        assign alusrca[i] = forward.forwards[i].valid1 ? 
                            forward.data[forward.forwards[i].fw1] :
                            dataI.alu_issue[i].src1;
        assign alusrcb[i] = forward.forwards[i].valid2 ? 
                            forward.data[forward.forwards[i].fw2] :
                            dataI.alu_issue[i].src2;
        assign forward.src1[i] = dataI.alu_issue.r1;
        assign forward.src2[i] = dataI.alu_issue.r2;
    end
    for (genvar i = 0; i < MEM_NUM ; i++) begin
        assign agusrca[i] = forward.forwards[i].valid1 ? 
                            forward.data[forward.forwards[i].fw1] :
                            dataI.agu_issue[i].src1;
        assign agusrcb[i] = forward.forwards[i].valid2 ? 
                            forward.data[forward.forwards[i].fw2] :
                            dataI.agu_issue[i].src2;
        assign forward.src1[i] = dataI.agu_issue.r1;
        assign forward.src2[i] = dataI.agu_issue.r2;
    end
    for (genvar i = 0; i < BRANCH_NUM ; i++) begin
        assign brusrca[i] = forward.forwards[i].valid1 ? 
                            forward.data[forward.forwards[i].fw1] :
                            dataI.branch_issue[i].src1;
        assign brusrcb[i] = forward.forwards[i].valid2 ? 
                            forward.data[forward.forwards[i].fw2] :
                            dataI.branch_issue[i].src2;
        assign forward.src1[i] = dataI.branch_issue.r1;
        assign forward.src2[i] = dataI.branch_issue.r2;
    end
    for (genvar i = 0; i < MULT_NUM ; i++) begin
        assign multsrca[i] = forward.forwards[i].valid1 ? 
                            forward.data[forward.forwards[i].fw1] :
                            dataI.mult_issue[i].src1;
        assign multsrcb[i] = forward.forwards[i].valid2 ? 
                            forward.data[forward.forwards[i].fw2] :
                            dataI.mult_issue[i].src2;
        assign forward.src1[i] = dataI.mult_issue.r1;
        assign forward.src2[i] = dataI.mult_issue.r2;
    end
    // ALU
    
    word_t [ALU_NUM-1:0]aluout;
    logic [ALU_NUM-1:0]exception_of;
    for (genvar i=0; i<ALU_NUM; i++) begin
        alu alu(.a(alusrca[i]), 
                .b(alusrcb[i]),
                .alufunc(dataI.alu_issue[i].ctl.alufunc),
                .c(aluout[i]),
                .exception_of(exception_of[i]));
    end
    always_comb begin
        for (int i=0; i<ALU_NUM; i++) begin
            dataE.alu_commit[i].data = aluout[i];
            dataE.alu_commit[i].rob_addr = dataI.alu_issue[i].dst;
            dataE.alu_commit[i].exception = dataI.alu_issue[i].exception;
            dataE.alu_commit[i].exception.of = exception_of[i];
        end
    end

    // MEM
    logic [MEM_NUM-1:0]exception_load, exception_save;
    word_t [MEM_NUM-1:0]aguout;
    vaddr_t [MEM_NUM-1:0]addr;
    for (genvar i=0; i<MEM_NUM; i++) begin
        agu agu(.clk, .resetn, 
                .memtoreg(dataI.mem_issue[i].ctl.memtoreg),
                .src1(dataI.mem_issue[i].src1), 
                .src2(dataI.mem_issue[i].imm),
                .rd_(rd), 
                .wd_(dataI.mem_issue[i].src2),
                .data(aguout[i]),
                .addr(addr[i]),
                .exception_load(exception_load[i]),
                .exception_save(exception_save[i])
                );
    end
    always_comb begin
        for (int i=0; i<MAX; i++) begin
            dataE.agu_commit[i].data = aguout[i];
            dataE.agu_commit[i].addr = addr[i];
            dataE.agu_commit[i].rob_addr = dataI.mem_issue[i].dst;
            dataE.agu_commit[i].exception = dataI.mem_issue[i].exception;
            dataE.agu_commit[i].exception.load = exception_load[i];
            dataE.agu_commit[i].exception.save = exception_save[i];
        end
    end
    assign mread.valid = dataI.mem_issue[0].ctl.memtoreg & exception_load[i];
    assign mread.addr = addr[0];
    // BRU
    for (genvar i=0; i<BRU_NUM; i++) begin
        bru bru();
    end

    // MULT
    for (genvar i=0; i<MULT_NUM; i++) begin
        mult mult();
    end

    // wake
    for (genvar i = 0; i < ALU_NUM ; i++) begin
        assign wake.dst_execute[i].id = dataI.alu_issue[i].dst;
        assign wake.dst_execute[i].valid = dataI.alu_issue[i].valid;
    end
    // ports
    assign dataI = ereg.dataI;
    assign creg.dataE_new = dataE;
endmodule