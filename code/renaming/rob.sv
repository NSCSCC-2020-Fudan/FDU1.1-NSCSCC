module rob 
    import common::*;
    import rob_pkg::*;
    import commit_pkt::*;(
    input logic clk, resetn, flush,
    rob_intf.rob rob
);

    // table
    entry_t[ROB_TABLE_LEN-1:0] rob_table, rob_table_new, rob_table_retire;

    // fifo ptrs
    rob_ptr_t head_ptr, tail_ptr;
    rob_addr_t head_addr, tail_addr;
    assign head_addr = head_ptr[ROB_ADDR_LEN-1:0];
    assign tail_addr = tail_ptr[ROB_ADDR_LEN-1:0];
    // fifo singals
    logic full, empty;

    // rob write
    w_req_t [PORT_NUM-1:0] w_req;
    w_resp_t [PORT_NUM-1:0] w_resp;
    retire_resp_t [ISSUE_WIDTH-1:0] retire_resp;
    // rob read
    r_req_t [PORT_NUM-1:0] r_req;
    // rob commit
    alu_commit_t[ALU_NUM-1:0] alu_commit;
    mem_commit_t[AGU_NUM-1:0] mem_commit;
    branch_commit_t[BRANCH_NUM-1:0] branch_commit;
    mult_commit_t[MULT_NUM-1:0] mult_commit;

    assign full = (head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
                  (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    assign empty = ~(head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
                    (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    
    assign exception_valid = rob_table[head_addr].exception.valid;

    always_comb begin
        rob_table_retire = rob_table;
        // commit first
        for (int i=0; i<ALU_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (alu_commit[i].valid && alu_commit[i].rob_addr == j) begin
                    rob_table_retire[j].data.alu.data = alu_commit[i].data;
                    rob_table_retire[j].complete = 1'b1;
                end
            end
        end
        for (int i=0; i<AGU_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (mem_commit[i].valid && mem_commit[i].rob_addr == j) begin
                    rob_table_retire[j].data.mem.data = mem_commit[i].data;
                    rob_table_retire[j].complete = 1'b1;
                end
            end
        end
        for (int i=0; i<BRANCH_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (branch_commit[i].valid && branch_commit[i].rob_addr == j) begin
                    rob_table_retire[j].complete = 1'b1;
                end
            end
        end
        for (int i=0; i<MULT_NUM; i++) begin
            for (int j=0; j<ROB_TABLE_LEN; j++) begin
                if (mult_commit[i].valid && mult_commit[i].rob_addr == j) begin
                    rob_table_retire[j].complete = 1'b1;
                end
            end
        end
        // retire

        // write
        rob_table_new = rob_table_retire;
    end

    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            rob_table <= '0;
        end else begin
            rob_table <= rob_table_new;
        end
    end
endmodule