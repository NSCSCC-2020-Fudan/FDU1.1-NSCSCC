`include "shared.svh"

module CP0(
    input logic clk, reset,

    output CP0_REGS cp0
);
    CP0_REGS cp0_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0 <= `CPO_INIT;
        end
        else begin
            cp0 <= cp0_new;
        end
    end
endmodule