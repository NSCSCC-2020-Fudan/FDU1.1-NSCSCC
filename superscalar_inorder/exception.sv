`include "mips.svh"

module exception(
        input logic reset,
        input logic [5: 0] ext_int,
        input exception_pipeline_t pipe,
        //input interrupt_info_t interrupt_info,
        //to pipeline commit
        output logic exception_valid,
        output word_t pcexception,
        //fetch control
        output exception_t exception,
        input cp0_regs_t cp0
        //cp0
        //input cp0_status_t cp0_status,
        //input cp0_cause_t cp0_cause
        //exception
    );

    // input logic reset,
    exc_code_t exccode;
    word_t vaddr;
    logic in_delay_slot;
    word_t pc;
    // interrupt
    interrupt_info_t interrupt_info;
    assign interrupt_info = pipe.interrupt_info;
    logic interrupt_valid;
    assign interrupt_valid = (interrupt_info != 0) // request
                           & (cp0.status.IE)
                        //    & (~cp0.debug.DM)
                           & (~cp0.status.EXL)
                           & (~cp0.status.ERL);
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
    
    assign exception.location = `EXC_ENTRY;
    assign exception.valid = (interrupt_valid | exception_valid) & ~reset;
    assign exception.code = (interrupt_valid) ? (`CODE_INT) : (exccode);
    assign exception.pc = pc;
    assign exception.in_delay_slot = in_delay_slot;
    assign exception.badvaddr = vaddr;

    assign exception_instr = pipe.exception_instr;
    assign exception_ri = pipe.exception_ri;
    assign exception_of = pipe.exception_of;
    assign exception_load =  pipe.exception_load;
    assign exception_bp = pipe.exception_bp;
    assign exception_sys = pipe.exception_sys;
    assign exception_save = pipe.exception_save;
    assign vaddr = pipe.vaddr;
    assign pc = pipe.pc;
    assign in_delay_slot = pipe.in_delay_slot;
    
    assign pcexception = `EXC_ENTRY;
    
endmodule