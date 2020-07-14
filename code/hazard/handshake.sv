`include "mips.svh"

module handshake (
    input logic clk, reset,
    input logic cpu_req,
    input logic addr_ok, data_ok,
    output logic cpu_data_ok, req
);
    assign cpu_data_ok = ~cpu_req | data_ok;
    always_ff @(posedge clk) begin
        if (reset) begin
            req <= 1'b0;
        end else if (~req) begin
            req <= cpu_req;
        end else if (addr_ok) begin
            req <= 1'b0;
        end
    end
endmodule