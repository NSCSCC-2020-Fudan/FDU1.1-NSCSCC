`include "interface.svh"
module hilo 
    import common::*;(
    input logic clk, resetn,
    retire_intf.hilo retire,
    payloadRAM_intf.hilo payloadRAM
);
    word_t hi, lo, hi_new, lo_new;
    always_comb begin
        hi_new = hi;
        lo_new = lo;
        for (int i=0; i<ISSUE_WIDTH; i++) begin
            case ({retire.retire[i].ctl.hiwrite, retire.retire[i].ctl.lowrite})
                2'b11: begin
                    hi_new = retire.retire[i].data.hilo.hi;
                    lo_new = retire.retire[i].data.hilo.lo;
                end
                2'b01: begin
                    lo_new = retire.retire[i].data[31:0];
                end
                2'b10: begin
                    hi_new = retire.retire[i].data[31:0];
                end
                default: begin
                    
                end
            endcase
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
    assign payloadRAM.hi = hi_new;
    assign payloadRAM.lo = lo_new;
endmodule