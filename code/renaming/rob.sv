module rob (
    
);
    // import common::*;
    import rob_pkg::*;

    // table
    entry_t[2**ROB_ADDR_LEN-1:0] rob_table, rob_table_new;

    // fifo ptrs
    rob_ptr_t head_ptr, tail_ptr;
    rob_addr_t head_addr, tail_addr;
    assign head_addr = head_ptr[ROB_ADDR_LEN-1:0];
    assign tail_addr = tail_ptr[ROB_ADDR_LEN-1:0];
    // fifo singals
    logic full, empty;

    // rob write
    w_req_t [PORT_NUM-1:0] w_req;

    // rob read
    r_req_t [PORT_NUM-1:0] r_req;

    assign full = (head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
                  (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    assign empty = ~(head_ptr[ROB_ADDR_LEN] ^ tail_ptr[ROB_ADDR_LEN]) && 
                    (head_ptr[ROB_ADDR_LEN-1:0] == tail_ptr[ROB_ADDR_LEN-1:0]);
    
    assign exception_valid = rob_table[head_addr].exception.valid;

    always_comb begin
        
    end

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            rob_table <= '0;
        end else begin
            rob_table <= rob_table_new;
        end
    end
endmodule