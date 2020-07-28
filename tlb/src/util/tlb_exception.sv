`include "tlb_bus.svh"
`include "exception.svh"
`include "cp0.svh"

module tlb_except(
    input   logic               tlb_refill,
    input   cp0_cause_t         cause,
    input   cp0_status_t        status,
    output  exception_offset    offset,

);

always_comb begin
    if (!status.EXL) begin
        if (tlb_refill && (cause.exccode == CODE_TLBL || cause.exccode == CODE_TLBS)) begin
            offset = 12'h000;

        end
    end else begin
        offset = 12'h180;
    end
end