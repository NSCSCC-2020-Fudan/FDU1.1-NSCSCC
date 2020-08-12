`include "mips.svh"
`include "tu.svh"

module exception_checker(
        input logic reset, flush,
        input exec_data_t in, 
        input logic [5: 0] ext_int,
        input logic timer_interrupt,
        output logic exception_valid,
        output word_t pcexception,
        output exception_t exception_data,
        output exec_data_t _out,
        input cp0_status_t cp0_status,
        input cp0_cause_t cp0_cause,
        input tu_op_resp_t tu_op_resp
    );
    
    logic exception_valid_;
    word_t pcexception_;
    exception_t exception_data_;
    exec_data_t _out_; 
    
    exec_data_t data;
    assign data = (~reset) ? ('0) : (in);
    assign _out_ = (exception_valid_) ? ('0) : (data);
    
    decoded_op_t op;
    assign op = data.instr.op;
    word_t aluoutM;
    assign aluoutM = data.result;
    
    logic exception_load, exception_save, exception_sys, exception_bp;
    assign exception_load = ((op == LW) && (aluoutM[1:0] != '0)) ||
                            ((op == LH || op == LHU) && (aluoutM[0] != '0));
    assign exception_save = ((op == SW) && (aluoutM[1:0] != '0)) ||
                            ((op == SH) && (aluoutM[0] != '0));
    assign exception_sys = (data.instr.op == SYSCALL);
    assign exception_bp = (data.instr.op == BREAK);
    
    logic data_is_read, data_is_write, data_bus_en;
    assign data_is_write = data.instr.ctl.memwrite;
    assign data_is_read = data.instr.ctl.memtoreg;
    assign data_bus_en = data.instr.ctl.memwrite | data.instr.ctl.memtoreg;
              
    exception_pipeline_t pipe;             
    assign pipe.exc_info.tr = 1'b0;
    assign pipe.exc_info.cpu = 1'b0;
    assign pipe.exc_info.mod = tu_op_resp.d_tlb_modified & data_is_write;
    assign pipe.exc_info.load_tlb = tu_op_resp.d_tlb_invalid & data_is_read;//to be continue
    assign pipe.exc_info.save_tlb = tu_op_resp.d_tlb_invalid & data_is_write;//to be continue
    assign pipe.exc_info.instr_tlb = data.instr_tlb_invalid;//to be continue   
    assign pipe.tlb_refill = data.instr_tlb_refill | (tu_op_resp.d_tlb_refill & data_bus_en);//to be continue
                 
    assign pipe.exc_info.instr = data.exception_instr;
    assign pipe.exc_info.ri =  data.exception_ri;
    assign pipe.exc_info.of = data.exception_of;
    assign pipe.exc_info.load = exception_load;
    assign pipe.exc_info.save = exception_save;
    assign pipe.exc_info.sys = exception_sys;
    assign pipe.exc_info.bp = exception_bp;
    assign pipe.in_delay_slot = data.in_delay_slot;
    assign pipe.pc = data.pcplus4 - 32'd4;
    assign pipe.vaddr = (data.exception_instr) ? pipe.pc : data.result;
    assign pipe.interrupt_info = ({ext_int, 2'b00} | cp0_cause.IP | {/*1'b0*/timer_interrupt, 7'b0}) & cp0_status.IM;
    
    exception exception (.reset, .ext_int,
                         .pipe,
                         .exception_valid(exception_valid_), 
                         .pcexception(pcexception_), 
                         .exception(exception_data_), 
                         .cp0_status);  
                         
    assign exception_valid = (~flush && data.valid) ? (exception_valid_) : (1'b0);
    assign pcexception = (~flush && data.valid) ? (pcexception_) : ('0);
    assign exception_data = (~flush && data.valid) ? (exception_data_) : ('0);
    assign _out = (~flush && data.valid) ? (_out_) : ('0);                                                   
    
endmodule
