`include "shared.svh"

module Exception(
    input cp0_regs_t cp0,
    input logic[8:0] interrupt_info,

    output exception_t exception
);
    // interrupt    
    logic interrupt_valid;
    assign interrupt_valid = (interrupt_info != 0) // request
                           & (cp0.status.IE)
                           & (~cp0.debug.DM)
                           & (~cp0.status.EXL)
                           & (~cp0.status.ERL);


    exception_offset_t offset;

    assign exception.location = `EXC_BASE + offset;
endmodule