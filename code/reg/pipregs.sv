`include "mips.svh"

module Freg (
    input logic clk, reset,
    input word_t pcnext,
    output word_t pc
);
    always_ff @(posedge in.clk, posedge in.reset) begin
        if (in.reset) begin
            out.pc <= '0;
        end
        else if(~in.stall) begin
            out.pc <= in.pcnext;
        end
    end
endmodule
