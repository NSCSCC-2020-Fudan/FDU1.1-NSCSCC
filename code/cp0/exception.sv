`include "mips.svh"

module exception_(
    input logic reset,
    input cp0_regs_t cp0,
    input interrupt_info_t interrupt_info,
    input logic valid,
    input exc_code_t exccode,
    input word_t vaddr,
    input logic in_delay_slot,
    input word_t pc,
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
    always_comb begin
        if (cp0.status.EXL) begin
            offset = 12'h180;
        end else begin
            if (exccode == `CODE_TLBL || exccode == `CODE_TLBS) begin
                offset = 12'h000;
            end else begin
                if (cp0.status.BEV) begin
                    offset = 12'h200;
                end else begin
                    offset = 12'h180;
                end
            end
        end
    end
    assign exception.location = `EXC_BASE + offset;
    assign exception.valid = (interrupt_valid | valid) & ~reset;
    assign exception.code = (interrupt_valid) ? (`CODE_INT) : (exccode);
    assign exception.pc = pc;
    assign exception.in_delay_slot = in_delay_slot;
    assign exception.badvaddr = vaddr;
endmodule