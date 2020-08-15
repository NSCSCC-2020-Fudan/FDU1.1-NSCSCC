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
        input cp0_status_t cp0_status
        //cp0
        //input cp0_status_t cp0_status,
        //input cp0_cause_t cp0_cause
        //exception
    );

    // input logic reset,
    exc_code_t exc_code;
    word_t vaddr;
    logic in_delay_slot;
    word_t pc;
    exception_info_t exc_info;
    // interrupt
    interrupt_info_t interrupt_info;
    assign interrupt_info = pipe.interrupt_info;
    logic interrupt_valid;
    assign interrupt_valid = (interrupt_info != 0) // request
                           & (cp0_status.IE)
                        //    & (~cp0.debug.DM)
                           & (~cp0_status.EXL)
                           & (~cp0_status.ERL);

    logic tlb_refill;
    always_comb begin
        priority case (1'b1)
            interrupt_valid : begin exc_code = `CODE_INT; tlb_refill = 1'b0;end
            exc_info.instr : begin exc_code = `CODE_ADEL;tlb_refill = 1'b0;end
            exc_info.instr_tlb : begin exc_code = `CODE_TLBL;tlb_refill = pipe.tlb_refill;end
            exc_info.cpu: begin exc_code = `CODE_CPU;tlb_refill = 1'b0;end
            exc_info.ri: begin exc_code = `CODE_RI;tlb_refill = 1'b0;end
            exc_info.of: begin exc_code = `CODE_OF;tlb_refill = 1'b0;end
            exc_info.bp: begin exc_code = `CODE_BP;tlb_refill = 1'b0;end
            exc_info.sys: begin exc_code = `CODE_SYS;tlb_refill = 1'b0;end
            exc_info.tr: begin exc_code = `CODE_TR;tlb_refill = 1'b0;end
            exc_info.load: begin exc_code = `CODE_ADEL;tlb_refill = 1'b0;end
            exc_info.save: begin exc_code = `CODE_ADES;tlb_refill = 1'b0;end
            exc_info.load_tlb: begin exc_code = `CODE_TLBL;tlb_refill = pipe.tlb_refill;end
            exc_info.save_tlb: begin exc_code = `CODE_TLBS;tlb_refill = pipe.tlb_refill;end
            exc_info.mod: begin exc_code = `CODE_MOD;tlb_refill = 1'b0;end
            default: begin
                exc_code = '0;
                tlb_refill = 1'b0;
            end
        endcase
    end
        assign exc_info = pipe.exc_info;

    assign exception_valid = ((|exc_info) | interrupt_valid) & reset;
    assign exception.location = tlb_refill ? 32'hbfc00200 : `EXC_ENTRY;
    assign exception.valid = (exception_valid);
    assign exception.code = (interrupt_valid) ? (`CODE_INT) : (exc_code);
    assign exception.pc = pc;
    assign exception.in_delay_slot = in_delay_slot;
    assign exception.badvaddr = vaddr;

    // assign exception_instr = pipe.exception_instr;
    // assign exception_ri = pipe.exception_ri;
    // assign exception_of = pipe.exception_of;
    // assign exception_load =  pipe.exception_load;
    // assign exception_bp = pipe.exception_bp;
    // assign exception_sys = pipe.exception_sys;
    // assign exception_save = pipe.exception_save;
    assign vaddr = pipe.vaddr;
    assign pc = pipe.pc;
    assign in_delay_slot = pipe.in_delay_slot;
    
    assign pcexception = tlb_refill ? 32'hbfc00200 : `EXC_ENTRY;
    
endmodule