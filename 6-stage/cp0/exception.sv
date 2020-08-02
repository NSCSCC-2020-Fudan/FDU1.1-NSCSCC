`include "mips.svh"

module exception(
    input logic reset,
    exception_intf.excep ports,
    pcselect_intf.excep pcselect,
    hazard_intf.excep hazard
);

    // input logic reset,
    logic exception_instr, exception_ri, exception_of, exception_load, exception_bp, exception_sys;
    interrupt_info_t interrupt_info;
    logic exception_valid;
    exc_code_t exccode;
    word_t vaddr;
    logic in_delay_slot;
    word_t pc;
    exception_t exception;
    cp0_status_t cp0_status;
    // interrupt
    logic interrupt_valid;
    assign interrupt_valid = (interrupt_info != 0) // request
                           & (cp0_status.IE)
                        //    & (~cp0.debug.DM)
                           & (~cp0_status.EXL)
                           & (~cp0_status.ERL);
//    assign interrupt_valid = '0;

    always_comb begin
        if (interrupt_valid) begin
            exception_valid = 1'b1;
            exccode = `CODE_INT;
        end else if (exception_instr) begin
            exception_valid = 1'b1;
            exccode = `CODE_ADEL;
        end else if (exception_ri) begin
            exception_valid = 1'b1;
            exccode = `CODE_RI;
        end else if (exception_of) begin
            exception_valid = 1'b1;
            exccode = `CODE_OV;
        end else if (exception_sys) begin
            exception_valid = 1'b1;
            exccode = `CODE_SYS;
        end else if (exception_bp) begin
            exception_valid = 1'b1;
            exccode = `CODE_BP;
        end else if (exception_load) begin
            exception_valid = 1'b1;
            exccode = `CODE_ADEL;
        end else if (exception_save) begin
            exception_valid = 1'b1;
            exccode = `CODE_ADES;
        end else begin
            exception_valid = 1'b0;
            exccode = '0;
        end
    end
    // exception_offset_t offset;
    // always_comb begin
    //     if (cp0.status.EXL) begin
    //         offset = 12'h180;
    //     end else begin
    //         if (exccode == `CODE_TLBL || exccode == `CODE_TLBS) begin
    //             offset = 12'h000;
    //         end else begin
    //             if (cp0.status.BEV) begin
    //                 offset = 12'h200;
    //             end else begin
    //                 offset = 12'h180;
    //             end
    //         end
    //     end
    // end
    // assign exception.location = `EXC_BASE + offset;
    assign exception.location = `EXC_ENTRY;
    assign exception.valid = (interrupt_valid | exception_valid) & ~reset;
    assign exception.code = (interrupt_valid) ? (`CODE_INT) : (exccode);
    assign exception.pc = pc;
    assign exception.in_delay_slot = in_delay_slot;
    assign exception.badvaddr = vaddr;

    assign exception_instr = ports.exception_instr;
    assign exception_ri = ports.exception_ri;
    assign exception_of = ports.exception_of;
    assign exception_load =  ports.exception_load;
    assign exception_bp = ports.exception_bp;
    assign exception_sys = ports.exception_sys;
    assign exception_save = ports.exception_save;
    assign pcselect.exception_valid = exception_valid;
    assign pcselect.pcexception = `EXC_ENTRY;
    assign hazard.exception_valid = exception_valid;
    assign vaddr = ports.vaddr;
    assign pc = ports.pc;
    assign in_delay_slot = ports.in_delay_slot;
    assign ports.exception = exception;
    assign interrupt_info = ports.interrupt_info;
    assign cp0_status = ports.cp0_status;
endmodule