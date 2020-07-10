`include "mips.svh"

module hilo (
    input logic clk, reset,
    hilo_intf.hilo ports
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.hi <= '0;
            ports.lo <= '0;
        end else begin
            if (ports.hlwrite.wen_h) begin
                ports.hi <= ports.hlwrite.wd_h;
            end
            if (ports.hlwrite.wen_l) begin
                ports.lo <= ports.hlwrite.wd_l;
            end
        end
    end
endmodule