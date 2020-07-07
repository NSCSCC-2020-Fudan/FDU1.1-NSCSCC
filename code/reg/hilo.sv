module hilo (
    input logic clk, reset,
    input w_lohi_t w,
    output word_t hi, lo
);
    always_ff @(negedge clk, posedge reset) begin
        if (reset) begin
            hi <= '0;
            lo <= '0;
        end else begin
            if (w.en_h) begin
                hi <= w.wd_h;
            end
            if (w,en_l) begin
                lo <= w.wd_l;
            end
        end
    end
endmodule