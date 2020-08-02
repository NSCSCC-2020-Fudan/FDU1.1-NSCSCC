`include "mips.svh"

module hilo (
    input logic clk, reset,
    hilo_intf.hilo ports
);
    word_t hi, lo, hi_new, lo_new;
    always_comb begin
        hi_new = hi;
        lo_new = lo;
        if (ports.hlwrite.wen_h) begin
            hi_new = ports.hlwrite.wd_h;
        end
        if (ports.hlwrite.wen_l) begin
            lo_new = ports.hlwrite.wd_l;
        end
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            hi <= '0;
            lo <= '0;
        end else begin
            hi <= hi_new;
            lo <= lo_new;
        end
    end
    assign ports.hi = hi_new;
    assign ports.lo = lo_new;
endmodule