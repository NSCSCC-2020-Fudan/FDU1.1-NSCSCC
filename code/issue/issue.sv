module issue 
    import common::*;
    import issue_queue_pkg::*;
    import issue_pkg::*;(
    input clk, resetn, flush,
    input renaming_data_t dataR,
    output issue_data_t dataI
);
    write_req_t[WRITE_NUM-1:0] write;
    wake_req_t[WAKE_NUM-1:0] wake;
    read_resp_t[execute_pkg::ALU_NUM-1:0] alu_issue;
    read_resp_t[execute_pkg::MEM_NUM-1:0] mem_issue;
    read_resp_t[execute_pkg::BRANCH_NUM-1:0] branch_issue;
    read_resp_t[execute_pkg::MULT_NUM-1:0] mult_issue;

    // generate write from dataR
    for (genvar i=0; i<WRITE_NUM; i++) begin
        write[i].valid = 1'b1;
        write[i].entry_type = ;
        write[i].entry.dst = ;
        write[i].entry.src1.valid = ;
        write[i].entry.src1.id = ;
        write[i].entry.src1.data = ;
        write[i].entry.src2.valid = ;
        write[i].entry.src2.id = ;
        write[i].entry.src2.data = ;
        write[i].entry.ctl = ;
    end

    logic [3:0] full;
    issue_queue #(.QUEUE_LEN(ALU_QUEUE_LEN), .ENTRY_TYPE(ALU), .READ_NUM(execute_pkg::ALU_NUM))
        alu_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(alu_issue),
                        .wake,
                        .full(full[0]));
    
    issue_queue #(.QUEUE_LEN(MEM_QUEUE_LEN), .ENTRY_TYPE(MEM), .READ_NUM(execute_pkg::AGU_NUM))
        mem_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(mem_issue),
                        .wake,
                        .full(full[1]));
    
    issue_queue #(.QUEUE_LEN(BRANCH_QUEUE_LEN), .ENTRY_TYPE(BRANCH), .READ_NUM(execute_pkg::BRU_NUM))
        branch_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(branch_issue),
                        .wake,
                        .full(full[2]);

    issue_queue #(.QUEUE_LEN(MULT_QUEUE_LEN), .ENTRY_TYPE(MULT), .READ_NUM(execute_pkg::MULT_NUM))
        mult_issue_queue(.clk, .resetn, .flush,
                        .write,
                        .read(mult_issue),
                        .wake,
                        .full(full[3]);


endmodule