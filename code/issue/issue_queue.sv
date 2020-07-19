module issue_queue 
    import common::*;
    import queue_pkg::*;
    #(
    parameter type queue_t = alu_queue_t,
    parameter type ptr_t = alu_queue_ptr_t,
    parameter ADDR_WIDTH = $clog2(ALU_QUEUE_LEN)
)(
    
);
    queue_t queue, queue_new;
    ptr_t head, tail, head_new, tail_new;
    logic full, empty, full_new, empty_new;

    assign full = (head[ADDR_WIDTH] ^ tail[ADDR_WIDTH]) && 
                  (head[ADDR_WIDTH-1:0] == tail[ADDR_WIDTH-1:0]);
    assign empty = ~(head[ADDR_WIDTH] ^ tail[ADDR_WIDTH]) && 
                    (head[ADDR_WIDTH-1:0] == tail[ADDR_WIDTH-1:0]);
    assign full_new = (head_new[ADDR_WIDTH] ^ tail_new[ADDR_WIDTH]) && 
                  (head_new[ADDR_WIDTH-1:0] == tail_new[ADDR_WIDTH-1:0]);
    assign empty_new = ~(head_new[ADDR_WIDTH] ^ tail_new[ADDR_WIDTH]) && 
                    (head_new[ADDR_WIDTH-1:0] == tail_new[ADDR_WIDTH-1:0]);

    // write
    always_ff @(posedge clk) begin
        if (~resetn) begin
            queue <= '0;
        end else begin
            queue <= queue_new;
        end
    end

    always_comb begin
        queue_new = queue;
        for (int i=0; i<WRITE_NUM; i++) begin
            if (condition) begin
                pass
            end
        end
    end
endmodule