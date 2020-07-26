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
    
    
    // ALU
    word_t [ALU_NUM-1:0]aluout;
    logic [ALU_NUM-1:0]exception_of;
    for (genvar i=0; i<ALU_NUM; i++) begin
        alu alu(.a(dataI.alu_issue[i].src1), 
                .b(dataI.alu_issue[i].src2),
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

    // AGU
    logic [AGU_NUM-1:0]exception_load, exception_save;
    word_t [AGU_NUM-1:0]aguout;
    vaddr_t [AGU_NUM-1:0]addr;
    for (genvar i=0; i<AGU_NUM; i++) begin
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

    // wake in execute

    // ports
    assign dataI = ereg.dataI;
    assign creg.dataE_new = dataE;
endmodule