// renaming aliasing table
module rat (
    
);
    import common::*;
    import rat_pkg::*;
    // table
    table_t mapping_table;

    // write
    w_req_t [WRITE_NUM-1:0] w_req;
    logic [WRITE_NUM-1:0] wen;
    always_ff @(posedge clk) begin
        if (reset) begin
            mapping_table <= '0;
        end
        else begin
            for (int j=0; j<WRITE_NUM; j++) begin
                if (w_req[j].req) begin
                    
                end
            end
        end
    end
    assign wen[WRITE_NUM-1] = (w_req[WRITE_NUM].id != '0);
    always_comb begin
        for (int i=0; i<WRITE_NUM-1; i++) begin
            if (w_req[i].id != 0) begin
                wen[i] = 1'b1;
                for (int j=i+1; j<WRITE_NUM; j++) begin
                    if (w_req[i].id == w_req[j].id) begin
                        wen[i] = 1'b0;
                        break;
                    end
                end
            end else begin
                wen[i] = 1'b0;
            end
        end
    end
    // read
    r_req_t [READ_NUM-1:0] r_req;
    r_resp_t [READ_NUM-1:0] r_resp;
    for (genvar i=0; i<READ_NUM; i++) begin
        assign r_resp[i].preg_id = mapping_table[r_req[i].areg_id];
    end
    // r0 is always 0
    assign mapping_table[0].preg_id = '0;


endmodule