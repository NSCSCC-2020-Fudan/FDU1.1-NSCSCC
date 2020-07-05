`include "MIPS.svh"

module exception(
    input logic reset,
    input logic valid, isbranch,
    input logic [31:0]pc,
    input logic [3:0]mode,
    input CP0_REG cp0,
    output Exception exception
);
    // interrupt
    logic interrupt_valid;
    assign interrupt_valid = (cp0.Status.IE & ~cp0.Status.EXL & (cp0.Cause.IP & cp0.Status.IM != '0));

    assign exception.valid = (valid | interrupt) & ~reset;
    assign exception.mode = mode;
    assign exception.pc = pc;
    assign exception.isbranch = isbranch;
    logic [11:0] offset;
    always_comb begin
        if(~cp0.Status.EXL && cp0.Cause.IV && exception.mode == `INT)
            offset <= 12'h200;
        else
            offset <= 12'h180;
    end

    assign exception.wa = 32'hbfc00200 + offset;
endmodule