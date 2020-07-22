module renaming 
    import common::*;(
    input logic clk, resetn,

);
    free_list_pkg::w_req_t [free_list_pkg::WRITE_PORTS-1:0] free_list_write;
    free_list_pkg::w_req_t [free_list_pkg::RELEASE_PORTS-1:0] free_list_rel;
    free_list_pkg::r_resp_t [free_list_pkg::READ_PORTS-1:0] free_list_read;
    logic free_list_full;

    free_list free_list(.clk, .resetn, .rel(free_list_rel), .write(free_list_write),
                        .read(free_list_read), .full(free_list_full));
    
    ra

    rat
endmodule