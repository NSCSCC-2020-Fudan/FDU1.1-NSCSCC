`include "interface.svh"

module mem_ctrl 
    import common::*;(
    input logic clk, resetn, flush, ren, wen, d_data_ok,
    mem_ctrl_intf.mem_ctrl self
);
    localparam type state_t = enum logic[1:0]{INIT, WAIT_WRITE, WAIT_READ, WAIT};
    state_t state, state_new;
    always_comb begin
        state_new = state;
        case (state_new)
            INIT: begin
                if (self.mem_issued) begin
                    state_new = WAIT;
                end
            end
            WAIT_WRITE: begin
                if (d_data_ok) begin
                    state_new = INIT;
                end
            end
            WAIT_READ: begin
                if (d_data_ok) begin
                    state_new = INIT;
                end
            end
            WAIT: begin
                if (ren) begin
                    state_new = WAIT_READ;
                    if (d_data_ok) begin
                        state_new = INIT;
                    end
                end
                if (wen) begin
                    state_new = WAIT_WRITE;
                    if (d_data_ok) begin
                        state_new = INIT;
                    end
                end
            end
            default: begin
                state_new = INIT;
            end
        endcase
    end
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            state <= INIT;
        end else begin
            state <= state_new;
        end
    end
    assign self.wait_mem = state != INIT;
endmodule