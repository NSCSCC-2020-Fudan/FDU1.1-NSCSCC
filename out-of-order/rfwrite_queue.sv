module rfwrite_queue
    import common::*;(
        input logic clk, resetn,
        input rf_w_t [ISSUE_WIDTH-1: 0] rfw,
        input word_t [ISSUE_WIDTH-1: 0] rt_pc,
        output logic[3:0] debug_wb_rf_wen,
        output logic[4:0] debug_wb_rf_wnum,
        output word_t debug_wb_pc, debug_wb_rf_wdata
    );
    localparam type entry_t = struct packed{
        logic valid;
        logic[4:0] addr;
        word_t data;
        word_t pc;
    };
    localparam type queue_t = entry_t[255:0];
    localparam type addr_t = logic[7:0]; 

    addr_t head, tail, head_new, tail_new;
    queue_t queue, queue_new;

    always_ff @(posedge clk) begin
        if (~resetn) begin
            head <= '0;
            tail <= '0;
            queue <= '0;
        end
        else begin
            head <= head_new;
            tail <= tail_new;
            queue <= queue_new;
        end
    end

    always_comb begin
        head_new = head;
        tail_new = tail;
        queue_new = queue;
        // read
        debug_wb_rf_wen = '0;
        debug_wb_rf_wnum = '0;
        debug_wb_pc = '0;
        debug_wb_rf_wdata = '0;
        if (head_new != tail_new && queue_new[head_new].valid) begin
            debug_wb_rf_wen = {4{queue_new[head_new].valid}};
            debug_wb_rf_wnum = queue_new[head_new].addr;
            debug_wb_pc = queue_new[head_new].pc;
            debug_wb_rf_wdata = queue_new[head_new].data;
            head_new = head_new + 1;
        end

        // write
        for (int i=0; i<ISSUE_WIDTH; i++) begin
            for (int j=0; j<256; j++) begin
                if (rfw[i].wen && tail_new == j) begin
                    queue_new[j].valid = rfw[i].wen;
                    queue_new[j].addr = rfw[i].addr;
                    queue_new[j].data = rfw[i].wd;
                    queue_new[j].pc = rt_pc[i] - 8;
                    tail_new = tail_new + 1;
                    break;
                end
            end
        end
    end
    
endmodule
