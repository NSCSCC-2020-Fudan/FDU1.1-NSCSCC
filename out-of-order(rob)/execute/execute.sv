`include "interface.svh"

module execute 
    import common::*;
    import execute_pkg::*;
    import decode_pkg::*;(
    input clk, resetn, flush,
    ereg_intf.execute ereg,
    creg_intf.execute creg,
    forward_intf.execute forward,
    wake_intf.execute wake,
    input logic d_data_ok,
    output m_r_t mread,
    input word_t rd,
    output logic mult_ok
);
    issue_pkg::issue_data_t dataI;
    execute_data_t dataE;
    // forward
    word_t [ALU_NUM-1:0]alusrca, alusrcb;
    word_t [MEM_NUM-1:0]memsrca, memsrcb;
    word_t [BRU_NUM-1:0]brusrca, brusrcb;
    word_t [MULT_NUM-1:0]multsrca, multsrcb;
    for (genvar i = 0; i < ALU_NUM ; i++) begin
        assign alusrca[i] = forward.forwards[i].valid1 & dataI.alu_issue[i].forward_en1 ? 
                            forward.data[forward.forwards[i].fw1] :
                            dataI.alu_issue[i].src1;
        assign alusrcb[i] = forward.forwards[i].valid2 & dataI.alu_issue[i].forward_en2 ? 
                            forward.data[forward.forwards[i].fw2] :
                            dataI.alu_issue[i].src2;
        assign forward.src1[i] = dataI.alu_issue[i].r1;
        assign forward.src2[i] = dataI.alu_issue[i].r2;
    end
    for (genvar i = 0; i < MEM_NUM ; i++) begin
        assign memsrca[i] = forward.forwards[i + ALU_NUM].valid1 & dataI.mem_issue[i].forward_en1 ? 
                            forward.data[forward.forwards[i + ALU_NUM].fw1] :
                            dataI.mem_issue[i].src1;
        assign memsrcb[i] = forward.forwards[i + ALU_NUM].valid2 & dataI.mem_issue[i].forward_en2 ? 
                            forward.data[forward.forwards[i + ALU_NUM].fw2] :
                            dataI.mem_issue[i].src2;
        assign forward.src1[i + ALU_NUM] = dataI.mem_issue[i].r1;
        assign forward.src2[i + ALU_NUM] = dataI.mem_issue[i].r2;
    end
    for (genvar i = 0; i < BRU_NUM ; i++) begin
        assign brusrca[i] = forward.forwards[i + ALU_NUM + MEM_NUM].valid1 & dataI.branch_issue[i].forward_en1 ? 
                            forward.data[forward.forwards[i + ALU_NUM + MEM_NUM].fw1] :
                            dataI.branch_issue[i].src1;
        assign brusrcb[i] = forward.forwards[i + ALU_NUM + MEM_NUM].valid2 & dataI.branch_issue[i].forward_en2 ? 
                            forward.data[forward.forwards[i + ALU_NUM + MEM_NUM].fw2] :
                            dataI.branch_issue[i].src2;
        assign forward.src1[i + ALU_NUM + MEM_NUM] = dataI.branch_issue[i].r1;
        assign forward.src2[i + ALU_NUM + MEM_NUM] = dataI.branch_issue[i].r2;
    end
    for (genvar i = 0; i < MULT_NUM ; i++) begin
        assign multsrca[i] = forward.forwards[i + ALU_NUM + MEM_NUM + BRU_NUM].valid1 & dataI.mult_issue[i].forward_en1 ? 
                            forward.data[forward.forwards[i + ALU_NUM + MEM_NUM + BRU_NUM].fw1] :
                            dataI.mult_issue[i].src1;
        assign multsrcb[i] = forward.forwards[i + ALU_NUM + MEM_NUM + BRU_NUM].valid2 & dataI.mult_issue[i].forward_en2 ? 
                            forward.data[forward.forwards[i + ALU_NUM + MEM_NUM + BRU_NUM].fw2] :
                            dataI.mult_issue[i].src2;
        assign forward.src1[i + ALU_NUM + MEM_NUM + BRU_NUM] = dataI.mult_issue[i].r1;
        assign forward.src2[i + ALU_NUM + MEM_NUM + BRU_NUM] = dataI.mult_issue[i].r2;
    end
    // ALU
    
    word_t [ALU_NUM-1:0]aluout;
    logic [ALU_NUM-1:0]exception_of;
    for (genvar i=0; i<ALU_NUM; i++) begin
        alu alu(.a(dataI.alu_issue[i].ctl.shamt_valid ? dataI.alu_issue[i].imm :alusrca[i]), 
                .b(dataI.alu_issue[i].ctl.alusrc == IMM ? dataI.alu_issue[i].imm :alusrcb[i]),
                .alufunc(dataI.alu_issue[i].ctl.alufunc),
                .c(aluout[i]),
                .exception_of(exception_of[i]));
    end
    always_comb begin
        for (int i=0; i<ALU_NUM; i++) begin
            dataE.alu_commit[i].data = aluout[i];
            dataE.alu_commit[i].rob_addr = dataI.alu_issue[i].dst;
            dataE.alu_commit[i].valid = dataI.alu_issue[i].valid;
            dataE.alu_commit[i].exception = dataI.alu_issue[i].exception;
            dataE.alu_commit[i].exception.of = exception_of[i];
        end
    end

    // MEM
    logic [MEM_NUM-1:0]exception_load, exception_save;
    word_t [MEM_NUM-1:0]memout;
    vaddr_t [MEM_NUM-1:0]addr;
    for (genvar i=0; i<MEM_NUM; i++) begin
        mem mem(.clk, .resetn, .flush,
                .src1(memsrca[i]), 
                .src2(dataI.mem_issue[i].imm),
                .rd_(rd), 
                .wd_(memsrcb[i]),
                .d_data_ok,
                .mem_commit(dataE.mem_commit[i]),
                .mem_issue(dataI.mem_issue[i]),
                .mread
                );
    end
    // BRU
    for (genvar i=0; i<BRU_NUM; i++) begin
        bru bru(.src1(brusrca[i]),
                .src2(brusrcb[i]),
                .pcplus8(dataI.branch_issue[i].pcplus8),
                .imm(dataI.branch_issue[i].imm),
                .branch_type(dataI.branch_issue[i].ctl.branch_type),
                .branch_taken(dataE.branch_commit[i].branch_taken),
                .pcbranch(dataE.branch_commit[i].pcbranch)
                );
        assign dataE.branch_commit[i].valid = dataI.branch_issue[i].valid;
        assign dataE.branch_commit[i].rob_addr = dataI.branch_issue[i].dst;
        assign dataE.branch_commit[i].exception = dataI.branch_issue[i].exception;
        assign dataE.branch_commit[i].data = dataI.branch_issue[i].pcplus8;
    end

    // MULT
    for (genvar i=0; i<MULT_NUM; i++) begin
        mult mult(.clk, .resetn, .flush,
                  .a(multsrca[i]),
                  .b(multsrcb[i]),
                  .op(dataI.mult_issue[i].op),
                  .mult_issue(dataI.mult_issue[i]),
                  .mult_commit(dataE.mult_commit[i]),
                  .ok(mult_ok)
                  );
        // assign dataE.mult_commit[i].valid = dataI.mult_issue[i].valid;
        // assign dataE.mult_commit[i].rob_addr = dataI.mult_issue[i].dst;
        // assign dataE.mult_commit[i].exception = dataI.mult_issue[i].exception;
    end

    // wake
    for (genvar i = 0; i < ALU_NUM ; i++) begin
        assign wake.dst_execute[i].id = dataI.alu_issue[i].dst;
        assign wake.dst_execute[i].valid = dataI.alu_issue[i].valid;
    end
    // self
    assign dataI = ereg.dataI;
    assign creg.dataE_new = dataE;
endmodule