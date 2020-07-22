module renaming 
    import common::*;
    import renaming_pkg::*;(
    input logic clk, resetn,
    input decoded_instr_t [ISSUE_NUM-1:0] instr,
    output renamed_instr_t [ISSUE_NUM-1:0] r_instr
);
    free_list_pkg::w_req_t [free_list_pkg::WRITE_PORTS-1:0] free_list_write;
    free_list_pkg::w_req_t [free_list_pkg::RELEASE_PORTS-1:0] free_list_rel;
    free_list_pkg::r_resp_t [free_list_pkg::READ_PORTS-1:0] free_list_resp;
    logic free_list_full;

    free_list free_list(.clk, .resetn, .rel(free_list_rel), .write(free_list_write),
                        .read(free_list_resp), .full(free_list_full));
    
    
                        

    rat_pkg::w_req_t [rat_pkg::WRITE_PORTS-1:0] rat_write;
    rat_pkg::r_req_t [rat_pkg::READ_PORTS-1:0] rat_read;
    rat_pkg::r_resp_t [rat_pkg::READ_PORTS-1:0] rat_resp;

    rat rat();
endmodule