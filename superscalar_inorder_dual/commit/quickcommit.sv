`include "mips.svh"

module quickcommit(
        input logic clk, reset, flushC,
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        //pipeline
        input logic first_cycleC, 
        output logic finishC, pc_mC,
        //control
        output logic dmem_wt,
        output word_t dmem_addr, dmem_wd, 
        input word_t dmem_rd,
        output logic dmem_en, dmem_req,
        output logic [1: 0] dmem_size,     
        input logic dmem_addr_ok, dmem_data_ok,
        //dmem
        output pc_data_t fetch,
        //fetch new pc
        output bypass_upd_t bypass0, bypass1,
        //data forward
        input logic [5: 0] ext_int,
        input logic timer_interrupt,
        output logic exception_valid,
        output exception_t exception_data,
        output logic is_eret,
        //cp0
        output word_t pc_commitC,
        output logic predict_wen,
        output bpb_result_t destpc_commitC
        //branch predict
    );
    
    exec_data_t [1: 0] exception_out;
    exception_t exception_data_ex;
    logic exception_valid_ex, exception_valid_dt, finish_exception;
    exceptioncommit exceptioncommit(.clk, .reset, .flush(flushC), .stall(~finishC),
    								.mask(exception_valid_dt),
									.in, .out(exception_out),
									.dmem_addr_ok, .dmem_req, 
									.dmem_en,
									.dmem_wt, .dmem_addr, .dmem_wd,
        							.dmem_size, 
        							.ext_int,
        							.timer_interrupt,
        							.exception_valid(exception_valid_ex), .exception_data(exception_data_ex),
        							.bypass(bypass0),
        							.finish_exception);
	
	logic [1: 0] dmem_size_dt;
	exec_data_t [1: 0] cdata_in;
    exception_t exception_data_dt;
    logic dmem_en_dt, finish_exception;
	
	always_ff @(posedge clk)
		begin
			if (~reset || exception_valid_dt)
				begin
					cdata_in <= '0;
					exception_data_dt <= '0;
					exception_valid_dt <= 1'b0;
					dmem_en_dt <= 1'b0;
					dmem_size_dt <= '0;
				end
			else				
				if (finishC) 
					begin
						cdata_in <= exception_out;
						exception_data_dt <= exception_data_ex;
						exception_valid_dt <= exception_valid_ex;
						dmem_en_dt <= dmem_en;
						dmem_size_dt <= dmem_size;
					end
		end        							
	     
	logic finish_cdata;
	datacommit datacommit(.clk, .reset, .stall(~finishC),
						  .in(cdata_in), .out,
						  .fetch,
						  .pc_commitC, .predict_wen, .destpc_commitC,
        				  .exception_valid(exception_valid_dt),
        			      .exception_data_in(exception_data_dt),
        			      .exception_data_out(exception_data),
        				  .bypass(bypass1),
        				  .dmem_en(dmem_en_dt),
        				  .dmem_size(dmem_size_dt),
        				  .dmem_rd,
        				  .dmem_data_ok,
        				  .finish_cdata);
	
	assign finishC = finish_exception & finish_cdata;   
	assign exception_valid = exception_valid_dt;	
	assign pc_mC = fetch.branch | fetch.jump | fetch.jr | fetch.exception_valid | fetch.is_eret;
	assign is_eret = fetch.is_eret;						
           
endmodule