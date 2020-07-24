module renaming 
    import common::*;
    import renaming_pkg::*;(
    input logic clk, resetn
);
    decode_data_t [MACHINE_WIDTH-1:0] dataD;
    renaming_data_t [MACHINE_WIDTH-1:0] dataR;

    free_list_pkg::w_req_t [free_list_pkg::WRITE_PORTS-1:0] free_list_write;
    free_list_pkg::w_req_t [free_list_pkg::RELEASE_PORTS-1:0] free_list_rel;
    free_list_pkg::r_resp_t [free_list_pkg::READ_PORTS-1:0] free_list_resp;
    logic free_list_full;

    free_list free_list(.clk, .resetn, .rel(free_list_rel), .write(free_list_write),
                        .read(free_list_resp), .full(free_list_full));
    
    for (genvar i=0; i<free_list_pkg::WRITE_PORTS; i++) begin
        free_list_write[i].id = free_list_resp[i].id;
        free_list_write[i].valid = instr[i].dst != 0;
    end

    rat_pkg::w_req_t [rat_pkg::WRITE_PORTS-1:0] rat_write;
    rat_pkg::r_req_t [rat_pkg::READ_PORTS-1:0] rat_read;
    rat_pkg::r_resp_t [rat_pkg::READ_PORTS-1:0] rat_resp;
    rat_pkg::rel_req_t [rat_pkg::RELEASE_PORTS-1:0] rat_rel;

    rat rat(.clk, .resetn, .write(rat_write), .read(rat_read), 
            .resp(rat_resp), .rel(rat_rel), .free_list_resp);

    for (genvar i=0; i<rat_pkg::WRITE_PORTS; i++) begin
        rat_write[i].id = dataD[i].instr.dst;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        rat_read[i].id = dataD[i].instr.src1;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        rat_read[MACHINE_WIDTH + i].id = dataD[i].instr.src2;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        rat_read[2*MACHINE_WIDTH + i] = dataD[i].instr.dst;
    end

    areg_addr_t [MACHINE_WIDTH-1:0] src1, src2, dst;
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        src1[i] = dataD[i].instr.src1;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        src2[i] = dataD[i].instr.src2;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        dst[i] = dataD[i].instr.dst;
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