`include "mips.svh"

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
        input cp0_cause_t cp0_cause
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
              
    exception_pipeline_t pipe;                             
    assign pipe.exception_instr = data.exception_instr;
    assign pipe.exception_ri =  data.exception_ri;
    assign pipe.exception_of = data.exception_of;
    assign pipe.exception_load = exception_load;
    assign pipe.exception_save = exception_save;
    assign pipe.exception_sys = exception_sys;
    assign pipe.exception_bp = exception_bp;
    assign pipe.in_delay_slot = data.in_delay_slot;
    assign pipe.pc = data.pcplus4 - 32'd4;
    assign pipe.vaddr = (data.exception_instr) ? pipe.pc : data.result;
    assign pipe.interrupt_info = ({ext_int, 2'b00} | cp0_cause.IP | {/*1'b0*/timer_interrupt, 7'b0}) & cp0_status.IM;
    
    exception exception (reset, ext_int,
                         pipe,
                         exception_valid_, pcexception_, 
                         exception_data_, 
                         cp0_status);  
                         
    assign exception_valid = (~flush && data.valid) ? (exception_valid_) : (1'b0);
    assign pcexception = (~flush && data.valid) ? (pcexception_) : ('0);
    assign exception_data = (~flush && data.valid) ? (exception_data_) : ('0);
    assign _out = (~flush && data.valid) ? (_out_) : ('0);                                                   
    
endmodule
