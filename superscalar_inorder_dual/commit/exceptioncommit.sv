`include "mips.svh"
`include "data_bus.svh"

module exceptioncommit(
		input logic clk, reset, flush, stall,
		input logic mask,
		input exec_data_t [1: 0] in,
		output exec_data_t [1: 0] out,
		//pipeline,
		input logic dmem_addr_ok,
		output logic dmem_req, dmem_en,
		output logic dmem_wt,
        output word_t dmem_addr, dmem_wd,
        output logic [1: 0] dmem_size,
        output dbus_wrten_t dmem_write_en,  
        //mem
        input logic timer_interrupt, 
        input logic [5: 0] ext_int,
        output logic exception_valid,
        exception_t exception_data,
        output logic llwrite,
        //commmitdt
        output bypass_upd_t bypass,
        output logic finish_exception,
        output logic wait_ex,
        input logic llbit,
        //other
        input cp0_status_t cp0_status,
        input cp0_cause_t cp0_cause
        //cp0
    );
    
    logic [1: 0] _exception_valid;
    word_t [1: 0] _pcexception;
    exception_t [1: 0] _exception_data;
    word_t pcexception;
    exception_checker exception_checker1 (.reset, .flush(mask),
                                          .in(in[1]),
                                          .ext_int, .timer_interrupt,
                                          .exception_valid(_exception_valid[1]), .pcexception(_pcexception[1]), 
                                          .exception_data(_exception_data[1]),
                                          ._out(out[1]), //.llbit,
                                          .cp0_status, .cp0_cause);
    exception_checker exception_checker0 (.reset, .flush((_exception_valid[1]) | (in[1].instr.op == ERET) | (mask)),
                                          .in(in[0]),
                                          .ext_int, .timer_interrupt,
                                          .exception_valid(_exception_valid[0]), .pcexception(_pcexception[0]), 
                                          .exception_data(_exception_data[0]),
                                          ._out(out[0]), //.llbit,
                                          .cp0_status, .cp0_cause);
                                          
    assign exception_valid = _exception_valid[1] | _exception_valid[0];
    assign exception_data = (_exception_valid[1]) ? (_exception_data[1]) : (_exception_data[0]);    
    assign pcexception = (_exception_valid[1]) ? (_pcexception[1]) : (_pcexception[0]);
    
    assign bypass.destreg = {in[1].destreg, in[0].destreg};
    assign bypass.result = {in[1].result, in[0].result};
    assign bypass.hiwrite = {in[1].instr.ctl.hiwrite, in[0].instr.ctl.hiwrite};
    assign bypass.lowrite = {in[1].instr.ctl.lowrite, in[0].instr.ctl.lowrite};
    assign bypass.hidata = {in[1].hiresult, in[0].hiresult};
    assign bypass.lodata = {in[1].loresult, in[0].loresult};
    //assign bypass.memtoreg = {in[1].instr.ctl.memtoreg, in[0].instr.ctl.memtoreg};
    assign bypass.ready = {out[1].state.ready, out[0].state.ready};
    assign bypass.wen = {out[1].instr.ctl.regwrite, out[0].instr.ctl.regwrite};
    assign bypass.cp0_modify = {in[1].instr.ctl.cp0_modify, in[0].instr.ctl.cp0_modify};
    
    m_q_t [1: 0] _mem;
    dbus_wrten_t [1: 0] _write_en;
    writedata_format writedata_format1 (in[1], _mem[1], _write_en[1]);
    writedata_format writedata_format0 (in[0], _mem[0], _write_en[0]);
    assign dmem_addr = (in[1].instr.ctl.memwrite | in[1].instr.ctl.memtoreg) ? (in[1].result) : (in[0].result);
    assign dmem_size = (in[1].instr.ctl.memwrite | in[1].instr.ctl.memtoreg) ? (_mem[1].size) : (_mem[0].size);
    assign dmem_wt = (in[1].instr.ctl.memwrite | in[0].instr.ctl.memwrite);
    assign dmem_wd = (in[1].instr.ctl.memwrite | in[1].instr.ctl.memtoreg) ? (_mem[1].wd) : (_mem[0].wd);
    assign dmem_en = (out[1].instr.ctl.memwrite | out[1].instr.ctl.memtoreg) | 
    				 (out[0].instr.ctl.memwrite | out[0].instr.ctl.memtoreg);
    assign dmem_write_en = (in[1].instr.ctl.memwrite | in[1].instr.ctl.memtoreg) ? (_write_en[1]) : (_write_en[0]);    				   				 
	
	logic dmem_addr_ok_h;    				 
	assign dmem_req = dmem_en & ~dmem_addr_ok_h;
	always_ff @(posedge clk)
		begin
			if (~reset | flush | ~stall)
				begin
					dmem_addr_ok_h <= 1'b0;
				end
			else
				if (stall)
					begin
						dmem_addr_ok_h = dmem_addr_ok_h | dmem_addr_ok; 
					end				
		end    				 
    
    assign finish_exception = ~dmem_en | dmem_addr_ok | dmem_addr_ok_h;
    assign llwrite = out[1].instr.ctl.llwrite | out[0].instr.ctl.llwrite; 
    assign wait_ex = (out[1].instr.op == WAIT_EX) & (~exception_valid);
    
endmodule
