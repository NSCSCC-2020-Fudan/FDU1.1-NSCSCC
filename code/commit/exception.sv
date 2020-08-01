`include "interface.svh"
module exception
    import common::*;
    import exception_pkg::*;(
    input logic reset,
    exception_intf.excep self,
    pcselect_intf.exception pcselect,
    hazard_intf.exception hazard
);
    assign pcselect.exception_valid = 1'b0;
    /*
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
            exccode = CODE_INT;
        end else if (exception_instr) begin
            exception_valid = 1'b1;
            exccode = CODE_ADEL;
        end else if (exception_ri) begin
            exception_valid = 1'b1;
            exccode = CODE_RI;
        end else if (exception_of) begin
            exception_valid = 1'b1;
            exccode = CODE_OV;
        end else if (exception_sys) begin
            exception_valid = 1'b1;
            exccode = CODE_SYS;
        end else if (exception_bp) begin
            exception_valid = 1'b1;
            exccode = CODE_BP;
        end else if (exception_load) begin
            exception_valid = 1'b1;
            exccode = CODE_ADEL;
        end else if (exception_save) begin
            exception_valid = 1'b1;
            exccode = CODE_ADES;
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
    //         if (exccode == CODE_TLBL || exccode == CODE_TLBS) begin
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
    // assign exception.location = EXC_BASE + offset;
    assign exception.location = EXC_ENTRY;
    assign exception.valid = (interrupt_valid | exception_valid) & ~reset;
    assign exception.code = (interrupt_valid) ? (CODE_INT) : (exccode);
    assign exception.pc = pc;
    assign exception.in_delay_slot = in_delay_slot;
    assign exception.badvaddr = vaddr;

    assign exception_instr = self.exception_instr;
    assign exception_ri = self.exception_ri;
    assign exception_of = self.exception_of;
    assign exception_load =  self.exception_load;
    assign exception_bp = self.exception_bp;
    assign exception_sys = self.exception_sys;
    assign exception_save = self.exception_save;
    assign pcselect.exception_valid = exception_valid;
    assign pcselect.pcexception = EXC_ENTRY;
    assign hazard.exception_valid = exception_valid;
    assign vaddr = self.vaddr;
    assign pc = self.pc;
    assign in_delay_slot = self.in_delay_slot;
    assign self.exception = exception;
    assign interrupt_info = self.interrupt_info;
    assign cp0_status = self.cp0_status;
    */
endmodule