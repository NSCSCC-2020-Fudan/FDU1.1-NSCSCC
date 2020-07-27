`include "interface.svh"
module hilo 
    import common::*;(
    input logic clk, resetn,
    retire_intf.hilo retire
);
    word_t hi, lo, hi_new, lo_new;
    always_comb begin
        hi_new = hi;
        lo_new = lo;
        for (int i=0; i<ISSUE_WIDTH; i++) begin
            if (retire.retire[i].ctl.hiwrite) begin
                hi_new = retire.retire[i].data.hilo.hi;
            end
            if (retire.retire[i].ctl.lowrite) begin
                lo_new = retire.retire[i].data.hilo.lo;
            end
        end
    end
    always_ff @(posedge clk) begin
        if (~resetn) begin
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