module free_list     
    import common::*;
    import free_list_pkg::*;(
    input logic clk, resetn,
    input w_req_t [RELEASE_PORTS-1:0] rel,
    input w_req_t [WRITE_PORTS-1:0] write,
    output r_resp_t [READ_PORTS-1:0] read,
    output logic full
);


    // free list
    free_list_t list, list_new, list_release;
    assign list[0] = 1'b1;

    // read and write
    // release -> read -> write

    always_comb begin
        list_release = list;
        // release
        for (int i=1; i<LIST_LEN; i++) begin
            for (int j=0; j<RELEASE_PORTS; j++) begin
                if (rel[j].valid && rel[j].id == i) begin
                    list_release[i].busy = 1'b0;
                end
            end
        end
        list_new = list_release;

        // read
        full = 1'b0;
        read = '0;
        for (int i=0; i<READ_PORTS; i++) begin
            for (int j=1; j<LIST_LEN; j++) begin
                if (~list_new[j].busy) begin
                    read[i].id = j;
                    break;
                end
            end
            if (read[i].id == 0) begin
                full = 1'b1;
                break;
            end
        end

        // write
        for (int i=1; i<LIST_LEN; i++) begin
            for (int j=0; j<WRITE_PORTS; j++) begin
                if (write[j].valid && write[j].id == i) begin
                    list_new[i].busy = 1'b1;
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if ( ~resetn ) begin
            list[LIST_LEN:1] <= '0;
        end else begin
            list[LIST_LEN:1] <= list_new[LIST_LEN:1];
        end
    end
endmodule