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
    
    for (genvar i=0; i<free_list_pkg::WRITE_PORTS; i++) begin
        free_list_write[i].id = free_list_resp[i].id;
        free_list_write[i].valid = instr[i].dst == 0;
    end
                        

    rat_pkg::w_req_t [rat_pkg::WRITE_PORTS-1:0] rat_write;
    rat_pkg::r_req_t [rat_pkg::READ_PORTS-1:0] rat_read;
    rat_pkg::r_resp_t [rat_pkg::READ_PORTS-1:0] rat_resp;

    rat rat(.clk, .resetn, .write(rat_write), .read(rat_read), 
            .resp(rat_resp), .free_list_resp);

    for (genvar i=0; i<rat_pkg::WRITE_PORTS; i++) begin
        rat_write[i].id = instr[i].dst;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        rat_read[i].id = instr[i].src1;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        rat_read[MACHINE_WIDTH + i].id = instr[i].src2;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        rat_read[2*MACHINE_WIDTH + i] = in.dst;
    end

    areg_addr_t [MACHINE_WIDTH-1:0] src1, src2, dst;
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        src1[i] = instr[i].src1;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        src2[i] = instr[i].src2;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        dst[i] = instr[i].dst;
    end
    preg_addr_t [MACHINE_WIDTH-1:0] psrc1, psrc2;
    raw_check raw_check(.psrc1_rat(rat_resp[MACHINE_WIDTH-1:0]),
                        .psrc2_rat(rat_resp[MACHINE_WIDTH*2-1:MACHINE_WIDTH]),
                        .pdst_fl(free_list_resp),
                        .src1,
                        .src2,
                        .dst,
                        .psrc1,
                        .psrc2);
endmodule