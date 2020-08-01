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
    pcselect_intf.rob pcselect,
    output m_w_t mwrite,
    input logic d_data_ok
    // mem_ctrl_intf.rob mem_ctrl
);
    // assign mwrite = '0;
    // table
    rob_table_t rob_table, rob_table_new, rob_table_retire;

    // fifo ptrs
    rob_ptr_t head_ptr, tail_ptr, head_ptr_new, tail_ptr_new, head_ptr_retire, tail_ptr_retire;
    rob_ptr_t head_ptr_temp, head_ptr_b;
    rob_addr_t head_addr, tail_addr, head_addr_new, tail_addr_new, head_addr_retire, tail_addr_retire;
    rob_addr_t head_addr_b;
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

    // assign full = (head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
    //               (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    // assign empty = ~(head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
    //                 (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    
    logic exception_valid;
    // assign exception_valid = rob_table[head_addr].exception.valid;
    assign exception_valid = 1'b0;

    logic branch_taken;
    assign head_ptr_b = head_ptr_new - 2;
    assign head_addr_b = head_ptr_b[ROB_ADDR_LEN-1:0];
    assign branch_taken = rob_table[head_addr_b].data.branch.branch_taken &&
                          (rob_table[head_addr_b].ctl.branch ||
                          rob_table[head_addr_b].ctl.jump
                          );
    m_w_t mwrite_new;
    logic[9:0] ds_counter;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            mwrite <= '0;
        end else if (d_data_ok) begin
            mwrite <= mwrite_new;
        end
    end
    always_comb begin
        rob_table_retire = rob_table;
        head_ptr_retire = head_ptr;
        // commit first
        for (int i=0; i<ALU_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (alu_commit[i].valid && alu_commit[i].rob_addr == j) begin
                    rob_table_retire[j].data.alu.zeros = '0;
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
                    rob_table_retire[j].data.mem.addr = mem_commit[i].addr;
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
                    rob_table_retire[j].data.branch.zeros = '0;
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
        retire.wb_pc = '0;
        mwrite_new = '0;

        ds_counter = 10'b10_0000_0000;
        
        head_ptr_temp = '0;
        for (int i=0; i<ISSUE_WIDTH; i++) begin
            if (head_ptr_retire == tail_ptr) begin
                break;
            end
            // check exception
            // if (exception_valid) begin
            //     break;
            // end
            
            // write register
            if (~rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].complete) begin
                break;
            end
            head_ptr_temp = head_ptr_retire - 2;
            if (ds_counter == 10'b0 || (rob_table[head_ptr_temp[ROB_ADDR_LEN-1:0]].data.branch.branch_taken &&
                          (rob_table[head_ptr_temp[ROB_ADDR_LEN-1:0]].ctl.branch ||
                          rob_table[head_ptr_temp[ROB_ADDR_LEN-1:0]].ctl.jump))) begin
                break;
            end
            ds_counter = {1'b0, ds_counter[9:1]};
            if (rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].data.branch.branch_taken &&
                (rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.branch || 
                rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.jump)) begin
                if (i == ISSUE_WIDTH - 1) begin
                    break;
                end
                head_ptr_temp = head_ptr_retire + 1;
                if (head_ptr_temp == tail_ptr || ~rob_table_retire[head_ptr_temp[ROB_ADDR_LEN-1:0]].complete) begin
                    break;
                end
                ds_counter = 10'b1;
                // branch_taken = 1'b1;
            end
            retire.retire[i].valid = 1'b1;
            retire.retire[i].ctl = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl;
            retire.retire[i].data = (rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.branch || 
                rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.jump)? 
                {32'b0, rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].pcplus8} : 
                rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].data[63:0];
            retire.retire[i].dst = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].creg;
            retire.retire[i].preg = head_ptr_retire[ROB_ADDR_LEN-1:0];
            rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].creg = '0;
            retire.wb_pc[i] = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].pcplus8;
            if (rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.memwrite) begin
                mwrite_new.wen = 1'b1;
                mwrite_new.addr = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].data.mem.addr;
                mwrite_new.size = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].ctl.msize;
                mwrite_new.wd = rob_table_retire[head_ptr_retire[ROB_ADDR_LEN-1:0]].data.mem.data;
            end
            // rob_table_retire[head_addr_retire] = '0;
            // update head_ptr
            // check branch
            

            head_ptr_retire = head_ptr_retire + 1;
            
        end

        // write
        rob_table_new = rob_table_retire;
        head_ptr_new = head_ptr_retire;
        tail_ptr_new = tail_ptr;
        full = '0;
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            if (head_ptr_new[ROB_ADDR_LEN-1:0] == tail_ptr_new[ROB_ADDR_LEN-1:0] && head_ptr_new[ROB_ADDR_LEN] != tail_ptr_new[ROB_ADDR_LEN]) begin
                rob_table_new = rob_table_retire;
                head_ptr_new = head_ptr_retire;
                tail_ptr_new = tail_ptr;
                full = 1'b1;
                break;
            end
            renaming.rob_addr_new[i] = tail_ptr_new[ROB_ADDR_LEN-1:0];
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (renaming.instr[i].valid && j == tail_ptr_new[ROB_ADDR_LEN-1:0]) begin
                    rob_table_new[j].complete = 1'b0;
                    rob_table_new[j].preg = tail_ptr_new[ROB_ADDR_LEN-1:0];
                    rob_table_new[j].creg = renaming.instr[i].dst;
                    rob_table_new[j].pcplus8 = renaming.instr[i].pcplus8;
                    rob_table_new[j].ctl = renaming.instr[i].ctl;
                    if (j == ROB_TABLE_LEN - 1) begin
                        rob_table_new[0].in_delay_slot = rob_table_new[j].ctl.branch | rob_table_new[j].ctl.jump;
                    end else begin
                        rob_table_new[j + 1].in_delay_slot = rob_table_new[j].ctl.branch | rob_table_new[j].ctl.jump;
                    end
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

    assign hazard.rob_full = full;
    assign hazard.branch_taken = branch_taken;
    assign pcselect.branch_taken = branch_taken;
    assign pcselect.pcbranch = rob_table_new[head_addr_b].data.branch.pcbranch;
    
    // commit
    assign alu_commit = commit.alu_commit;
    assign mem_commit = commit.mem_commit;
    assign branch_commit = commit.branch_commit;
    assign mult_commit = commit.mult_commit;
    
endmodule