module free_list (
    
);
    import common::*;
    import free_list_pkg::*;

    // free list
    free_list_t list, list_new, list_release;
    assign list[0] = 1'b1;

    // read and write
    // release -> read -> write
    w_req_t [RELEASE_PORTS-1:0] rel;
    w_req_t [WRITE_PORTS-1:0] write;
    r_resp_t [READ_PORTS-1:0] read;
    logic full;
    always_comb begin
        list_release = list;
        // release
        for (int i=1; i<PREG_NUM; i++) begin
            for (int j=0; j<RELEASE_PORTS; j++) begin
                if (rel[j].valid && rel[j].id == i) begin
                    list_release[i].busy = 1'b0;
                end
            end
        end
        list_new = list_release;
        // read
        full = 1'b0;
        for (int i=0; i<READ_PORTS; i++) begin
            
        end
        // write
    end

    always_ff @(posedge clk) begin
        if ( resetn ) begin
            list[PREG_NUM:1] <= '0;
        end else begin
            list[PREG_NUM:1] <= list_new[PREG_NUM:1];
        end
    end
endmodule