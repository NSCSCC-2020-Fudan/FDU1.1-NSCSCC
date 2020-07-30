module issue_queue 
    import common::*;
    import issue_queue_pkg::*;
    #(
    parameter QUEUE_LEN = ALU_QUEUE_LEN,
    parameter entry_type_t ENTRY_TYPE = ALU,
    parameter READ_NUM = execute_pkg::ALU_NUM
)(
    input logic clk, resetn, flush,
    input write_req_t [WRITE_NUM-1:0] write,
    output read_resp_t [READ_NUM-1:0] read,
    input wake_req_t [WAKE_NUM-1:0] wake,
    input word_t [ISSUE_WIDTH-1:0] broadcast,
    output logic full
);
    localparam type queue_ptr_t = logic[$clog2(QUEUE_LEN)-1:0];
    localparam type queue_t = entry_t[QUEUE_LEN-1:0];
    localparam ADDR_WIDTH = $clog2(QUEUE_LEN);

    queue_t queue, queue_new, queue_after_read;
    
    queue_ptr_t tail, tail_new, tail_after_read;
    write_req_t [WRITE_NUM-1:0] write_waken;
    logic[3:0] read_num;
    logic full_new;
    assign full_new = tail_new == '1;
    // write
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            queue <= '0;
            tail <= '0;
        end else begin
            queue <= queue_new;
            tail <= tail_new;
        end
    end
    // read and write
    always_comb begin
        queue_new = queue;
        tail_new = tail;
        full = 1'b0;
        read = '0;
        write_waken = write;
        // wake up
        for (int i=0; i<WAKE_NUM; i++) begin
            for (int j=0; j<QUEUE_LEN; j++) begin
                if (queue_new[j].src1.id == wake[i].id && wake[i].valid) begin
                    queue_new[j].src1.valid = 1'b1;
                    if (i < ISSUE_WIDTH) begin
                        queue_new[j].src1.data = broadcast[i];
                    end
                end
                if (queue_new[j].src2.id == wake[i].id && wake[i].valid) begin
                    queue_new[j].src2.valid = 1'b1;
                    if (i < ISSUE_WIDTH) begin
                        queue_new[j].src2.data = broadcast[i];
                    end
                end
                if (j == tail_new) begin
                    break;
                end
            end
            for (int j=0; j<WRITE_NUM; j++) begin
                if (write_waken[j].entry.src1.id == wake[i].id && wake[i].valid) begin
                    write_waken[j].entry.src1.valid = 1'b1;
                    if (i < ISSUE_WIDTH) begin
                        write_waken[j].entry.src1.data = broadcast[i];
                    end
                end
                if (write_waken[j].entry.src2.id == wake[i].id && wake[i].valid) begin
                    write_waken[j].entry.src2.valid = 1'b1;
                    if (i < ISSUE_WIDTH) begin
                        write_waken[j].entry.src2.data = broadcast[i];
                    end
                end
            end
        end

        // read first
        read_num = '0;
        for (int i=0; i<QUEUE_LEN; i++) begin
            // unable to read more
            if (read_num == READ_NUM) begin
                break;
            end
            if (i == tail_new) begin
                break;
            end
            // ready
            if (queue_new[i].src1.valid && queue_new[i].src2.valid) begin
                read[read_num] = queue_new[i];
                // remove from issue queue: queue_new[tail-1:i] = queue_new[tail:i+1];
                for (int j=0; j<QUEUE_LEN; j++) begin
                    if (j > i) begin
                        queue_new[j - 1] = queue_new[j];
                        if (j == tail_new) begin
                            break;
                        end
                    end
                end
                read_num = read_num + 1;
                tail_new = tail_new - 1;
            end

            // reach the last entry
            
        end
        queue_after_read = queue_new;
        tail_after_read = tail_new;
        // check read, else write
        for (int i=0; i<WRITE_NUM; i++) begin
            if (write_waken[i].entry_type != ENTRY_TYPE || ~write_waken[i].valid) begin
                continue; // not this type
            end else if (read_num != READ_NUM && write_waken[i].entry.src1.valid && write_waken[i].entry.src2.valid) begin
                read[read_num] = write_waken[i].entry; // issue immediately
            end else if (~full_new) begin
                queue_new[tail_new] = write_waken[i].entry; // push into the queue
                tail_new = tail_new + 1;
            end else begin
                tail_new = tail_after_read;
                queue_new = queue_after_read; // full
                full = 1'b1;
            end
        end
    end
endmodule