// renaming aliasing table
module rat 
    import common::*;
    import rat_pkg::*;(
    input logic clk, resetn,
    input w_req_t [WRITE_PORTS-1:0] write,
    input r_req_t [READ_PORTS-1:0] read,
    output r_resp_t [READ_PORTS-1:0] resp
);
    
    // table
    entry_t [TABLE_LEN-1:0] mapping_table, mapping_table_new;

    // write
    w_req_t [WRITE_PORTS-1:0] write;
    logic [WRITE_PORTS-1:0] wen;
    always_ff @(posedge clk) begin
        if (reset) begin
            mapping_table <= '0;
        end else begin
            mapping_table <= mapping_table_new;
        end
    end
    assign wen[WRITE_PORTS-1] = (write[WRITE_PORTS].id != '0);
    always_comb begin
        for (int i=0; i<WRITE_PORTS-1; i++) begin
            if (write[i].id != 0) begin
                wen[i] = 1'b1;
                for (int j=i+1; j<WRITE_PORTS; j++) begin
                    if (write[i].id == write[j].id) begin
                        wen[i] = 1'b0;
                        break;
                    end
                end
            end else begin
                wen[i] = 1'b0;
            end
        end
    end
    always_comb begin
        for (int i=0; i<TABLE_LEN; i++) begin
            for (int j=0; j<WRITE_PORTS; j++) begin
                if (wen[j] && write[j].id == i) begin
                    mapping_table_new[i].id = free_list_resp[j];
                end
            end
        end
    end
    // read
    r_req_t [READ_PORTS-1:0] r_req;
    r_resp_t [READ_PORTS-1:0] r_resp;
    for (genvar i=0; i<READ_PORTS; i++) begin
        assign r_resp[i].preg_id = mapping_table[r_req[i].areg_id];
    end
    // r0 is always 0
    assign mapping_table[0].preg_id = '0;


endmodule