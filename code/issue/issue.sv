`include "interface.svh"
module issue 
    import common::*;
    import issue_queue_pkg::*;
    import issue_pkg::*;(
    input clk, resetn,
    ireg_intf.issue ireg,
    ereg_intf.issue ereg,
    wake_intf.issue wake,
    payloadRAM_intf.issue payloadRAM
);
    renaming_pkg::renaming_data_t[MACHINE_WIDTH-1:0] dataR;
    issue_data_t dataI;
    write_req_t[WRITE_NUM-1:0] write;
    wake_req_t[WAKE_NUM-1:0] wake;
    read_resp_t[execute_pkg::ALU_NUM-1:0] alu_issue;
    read_resp_t[execute_pkg::MEM_NUM-1:0] mem_issue;
    read_resp_t[execute_pkg::BRANCH_NUM-1:0] branch_issue;
    read_resp_t[execute_pkg::MULT_NUM-1:0] mult_issue;

    // generate write from dataR
    for (genvar i=0; i<WRITE_NUM; i++) begin
        assign write[i].valid = 1'b1;
        assign write[i].entry_type = dataR[i].ctl.entry_type;
        assign write[i].entry.dst = dataR[i].dst;
        assign write[i].entry.src1.valid = dataR[i].src1.valid ? payloadRAM.prf1[i].valid : 1'b1;
        assign write[i].entry.src1.id = dataR[i].src1.id;
        assign write[i].entry.src1.data = dataR[i].src1.valid ? payloadRAM.cdata1[i] : payloadRAM.prf1[i].data;
        assign write[i].entry.src2.valid = dataR[i].src1.valid ? payloadRAM.prf1[i].valid : 1'b1;
        assign write[i].entry.src2.id = dataR[i].src2.id;
        assign write[i].entry.src2.data = dataR[i].src2.valid ? payloadRAM.cdata2[i] : payloadRAM.prf2[i].data;
        assign write[i].entry.ctl = dataR[i].ctl;
        assign write[i].entry.imm = dataR[i].imm;
        assign write[i].entry.pcplus8 = dataR[i].pcplus8;
        assign write[i].entry.exception = dataR[i].exception;
    end

    logic [3:0] full;
    word_t [ISSUE_NUM-1:0] broadcast;
    issue_queue #(.QUEUE_LEN(ALU_QUEUE_LEN), .ENTRY_TYPE(ALU), .READ_NUM(execute_pkg::ALU_NUM))
        alu_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(alu_issue),
                        .wake,
                        .full(full[0]),
                        .broadcast
                        );
    
    issue_queue #(.QUEUE_LEN(MEM_QUEUE_LEN), .ENTRY_TYPE(MEM), .READ_NUM(execute_pkg::MEM_NUM))
        mem_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(mem_issue),
                        .wake,
                        .full(full[1]),
                        .broadcast
                        );
    
    issue_queue #(.QUEUE_LEN(BRANCH_QUEUE_LEN), .ENTRY_TYPE(BRANCH), .READ_NUM(execute_pkg::BRU_NUM))
        branch_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(branch_issue),
                        .wake,
                        .full(full[2]),
                        .broadcast
                        );

    issue_queue #(.QUEUE_LEN(MULT_QUEUE_LEN), .ENTRY_TYPE(MULT), .READ_NUM(execute_pkg::MULT_NUM))
        mult_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(mult_issue),
                        .wake,
                        .full(full[3]),
                        .broadcast
                        );

    for (genvar i=0; i<ALU_NUM; i++) begin
        assign dataI.alu_issue[i].src1 = alu_issue[i].entry.src1.data;
        assign dataI.alu_issue[i].src2 = alu_issue[i].entry.src2.data;
        assign dataI.alu_issue[i].imm = alu_issue[i].entry.imm;
        assign dataI.alu_issue[i].dst = alu_issue[i].entry.dst;
        assign dataI.alu_issue[i].ctl = alu_issue[i].entry.ctl;
        assign dataI.alu_issue[i].pcplus8 = alu_issue[i].entry.pcplus8;
        assign dataI.alu_issue[i].exception = alu_issue[i].entry.exception;
    end
    for (genvar i=0; i<MEM_NUM; i++) begin
        assign dataI.mem_issue[i].src1 = mem_issue[i].entry.src1.data;
        assign dataI.mem_issue[i].src2 = mem_issue[i].entry.src2.data;
        assign dataI.mem_issue[i].imm = mem_issue[i].entry.imm;
        assign dataI.mem_issue[i].dst = mem_issue[i].entry.dst;
        assign dataI.mem_issue[i].ctl = mem_issue[i].entry.ctl;
        assign dataI.mem_issue[i].pcplus8 = mem_issue[i].entry.pcplus8;
        assign dataI.mem_issue[i].exception = mem_issue[i].entry.exception;
    end
    for (genvar i=0; i<BRANCH_NUM; i++) begin
        assign dataI.branch_issue[i].src1 = branch_issue[i].entry.src1.data;
        assign dataI.branch_issue[i].src2 = branch_issue[i].entry.src2.data;
        assign dataI.branch_issue[i].imm = branch_issue[i].entry.imm;
        assign dataI.branch_issue[i].dst = branch_issue[i].entry.dst;
        assign dataI.branch_issue[i].ctl = branch_issue[i].entry.ctl;
        assign dataI.branch_issue[i].pcplus8 = branch_issue[i].entry.pcplus8;
        assign dataI.branch_issue[i].exception = branch_issue[i].entry.exception;
    end
    for (genvar i=0; i<MULT_NUM; i++) begin
        assign dataI.mult_issue[i].src1 = mult_issue[i].entry.src1.data;
        assign dataI.mult_issue[i].src2 = mult_issue[i].entry.src2.data;
        assign dataI.mult_issue[i].imm = mult_issue[i].entry.imm;
        assign dataI.mult_issue[i].dst = mult_issue[i].entry.dst;
        assign dataI.mult_issue[i].ctl = mult_issue[i].entry.ctl;
        assign dataI.mult_issue[i].pcplus8 = mult_issue[i].entry.pcplus8;
        assign dataI.mult_issue[i].exception = mult_issue[i].entry.exception;
    end
    assign wake = {wake.dst_commit, wake.dst_execute};
    assign broadcast = wake.broadcast;
    assign dataR = ireg.dataR;
    assign ereg.dataI_new = dataI;
endmodule