`include "interface.svh"
module rob 
    import common::*;
    import rob_pkg::*;
    import commit_pkg::*;
    import execute_pkg::*;(
    input logic clk, resetn, flush,
    renaming_intf.rob renaming,
    commit_intf.rob commit,
    retire_intf.rob retire,
    payloadRAM_intf.rob payloadRAM,
    hazard_intf.rob hazard,
    output mem_pkg::write_req_t mwrite,
    input logic d_data_ok
);
    
    // table
    rob_table_t rob_table, rob_table_new, rob_table_retire;

    // fifo ptrs
    rob_ptr_t head_ptr, tail_ptr, head_ptr_new, tail_ptr_new, head_ptr_retire, tail_ptr_retire;
    rob_addr_t head_addr, tail_addr, head_addr_new, tail_addr_new, head_addr_retire, tail_addr_retire;
    assign head_addr = head_ptr[ROB_ADDR_LEN-1:0];
    assign tail_addr = tail_ptr[ROB_ADDR_LEN-1:0];
    assign head_addr_new = head_ptr_new[ROB_ADDR_LEN-1:0];
    assign tail_addr_new = tail_ptr_new[ROB_ADDR_LEN-1:0];
    assign head_addr_retire = head_ptr_retire[ROB_ADDR_LEN-1:0];
    assign tail_addr_retire = tail_ptr_retire[ROB_ADDR_LEN-1:0];
    // fifo singals
    logic full, empty;

    // rob write
    // w_req_t [PORT_NUM-1:0] w_req;
    // w_resp_t [PORT_NUM-1:0] w_resp;
//    retire_resp_t [ISSUE_WIDTH-1:0] retire_resp;
    // rob read
    // r_req_t [PORT_NUM-1:0] r_req;
    // rob commit
    alu_commit_t[ALU_NUM-1:0] alu_commit;
    mem_commit_t[MEM_NUM-1:0] mem_commit;
    branch_commit_t[BRU_NUM-1:0] branch_commit;
    mult_commit_t[MULT_NUM-1:0] mult_commit;

    assign full = (head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
                  (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    assign empty = ~(head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
                    (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    
    logic exception_valid;
    assign exception_valid = rob_table[head_addr].exception.valid;

    logic branch_taken;
    assign branch_taken = rob_table[head_addr_new].data.branch.branch_taken &&
                          rob_table[head_addr_new].ctl.branch;
    always_comb begin
        rob_table_retire = rob_table;
        head_ptr_retire = head_ptr;
        // commit first
        for (int i=0; i<ALU_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (alu_commit[i].valid && alu_commit[i].rob_addr == j) begin
                    rob_table_retire[j].data.alu.data = alu_commit[i].data;
                    rob_table_retire[j].complete = 1'b1;
                    rob_table_retire[j].exception = alu_commit[i].exception;
                end
            end
        end
        for (int i=0; i<MEM_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (mem_commit[i].valid && mem_commit[i].rob_addr == j) begin
                    rob_table_retire[j].data.mem.data = mem_commit[i].data;
                    rob_table_retire[j].complete = 1'b1;
                    rob_table_retire[j].exception = mem_commit[i].exception;
                end
            end
        end
        for (int i=0; i<BRU_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (branch_commit[i].valid && branch_commit[i].rob_addr == j) begin
                    rob_table_retire[j].complete = 1'b1;
                    rob_table_retire[j].exception = branch_commit[i].exception;
                    rob_table_retire[j].data.branch.pcbranch = branch_commit[i].pcbranch;
                    rob_table_retire[j].data.branch.branch_taken = branch_commit[i].branch_taken;
                end
            end
        end
        for (int i=0; i<MULT_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (mult_commit[i].valid && mult_commit[i].rob_addr == j) begin
                    rob_table_retire[j].complete = 1'b1;
                    rob_table_retire[j].exception = mult_commit[i].exception;
                end
            end
        end
        // retire
        retire.retire = '0;
        for (int i=0; i<ISSUE_WIDTH; i++) begin
            if (empty) begin
                break;
            end
            // check exception
            if (exception_valid) begin
                break;
            end
            // check branch
            if (rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].data.branch.branch_taken &&
                rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.branch) begin
                break;
            end
                // write delay slot

            // write register
            if (~rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].complete) begin
                break;
            end
            retire.retire[i].valid = 1'b1;
            retire.retire[i].ctl = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl;
            retire.retire[i].data = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].data[63:0];
            retire.retire[i].dst = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].creg;
            retire.wb_pc[i] = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].pcplus8;
            // rob_table_retire[head_addr_retire] = '0;
            // update head_ptr
            head_ptr_retire = head_ptr_retire + 1;
        end

        // write
        rob_table_new = rob_table_retire;
        head_ptr_new = head_ptr_retire;
        tail_ptr_new = tail_ptr;
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            renaming.rob_addr_new[i] = tail_ptr_new[ROB_ADDR_LEN-1:0];
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (renaming.instr[i].valid && j == tail_ptr_new[ROB_ADDR_LEN-1:0]) begin
                    rob_table_new[j].complete = 1'b0;
                    rob_table_new[j].preg = tail_ptr_new[ROB_ADDR_LEN-1:0];
                    rob_table_new[j].creg = renaming.instr[i].dst;
                    rob_table_new[j].pcplus8 = renaming.instr[i].pcplus8;
                    rob_table_new[j].ctl = renaming.instr[i].ctl;
                    // renaming.rob_addr_new[i] = rob_addr_t'(j);
                    tail_ptr_new += 1;
                    break;
                end
            end
            
        end

    end
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            rob_table <= '0;
            head_ptr <= '0;
            tail_ptr <= '0;
        end else begin
            rob_table <= rob_table_new;
            head_ptr <= head_ptr_new;
            tail_ptr <= tail_ptr_new;
        end
    end

    // payloadRAM
    for (genvar i = 0; i < MACHINE_WIDTH ; i++) begin
        assign payloadRAM.prf1[i].valid = rob_table_new[payloadRAM.preg1[i]].complete;
        assign payloadRAM.prf1[i].data = rob_table_new[payloadRAM.preg1[i]].data[31:0];
        assign payloadRAM.prf2[i].valid = rob_table_new[payloadRAM.preg2[i]].complete;
        assign payloadRAM.prf2[i].data = rob_table_new[payloadRAM.preg2[i]].data[31:0];
    end

    assign hazard.rob_full = 1'b0;
    assign hazard.branch_taken = branch_taken;
    assign pcselect.branch_taken = branch_taken;
    assign pcselect.pcbranch = rob_table_new[head_addr_new].data.branch.pcbranch;
    
    // commit
    assign alu_commit = commit.alu_commit;
    assign mem_commit = commit.mem_commit;
    assign branch_commit = commit.branch_commit;
    assign mult_commit = commit.mult_commit;
    
endmodule