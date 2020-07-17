module rob (
    
);
    // import common::*;
    import rob_pkg::*;

    // table
    rob_table_t rob_table;

    // fifo ptrs
    rob_ptr_t head_ptr, tail_ptr;

    // fifo singals
    logic full, empty;

    // rob write
    w_req_t [PORT_NUM-1:0] w_req;

    // rob read
    r_req_t [PORT_NUM-1:0] r_req;

    assign full = (head_ptr[ROB_TABLE_SIZE] ^ tail_ptr[ROB_TABLE_SIZE]) && 
                  (head_ptr[ROB_TABLE_SIZE-1:0] == tail_ptr[ROB_TABLE_SIZE-1:0]);
    assign empty = ~(head_ptr[ROB_TABLE_SIZE] ^ tail_ptr[ROB_TABLE_SIZE]) && 
                    (head_ptr[ROB_TABLE_SIZE-1:0] == tail_ptr[ROB_TABLE_SIZE-1:0]);
    
    
endmodule