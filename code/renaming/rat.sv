// renaming aliasing table
module rat (
    
);
    import common::*;
    import rat_pkg::*;
    // table
    table_t mapping_table;

    // write
    w_req_t [WRITE_NUM-1:0] write;
    // read
    r_req_t [READ_NUM-1:0] read;
    
endmodule