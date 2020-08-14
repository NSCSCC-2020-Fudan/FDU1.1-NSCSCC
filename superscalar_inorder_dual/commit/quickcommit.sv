`include "tu.svh"
`include "data_bus.svh"

module quickcommit(
        input logic clk, reset, flushC,
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        //pipeline
        input logic first_cycleC, 
        output logic finishC, pc_mC,
        //control
        /*
        output logic dmem_wt,
        output word_t dmem_addr, dmem_wd, 
        input word_t dmem_rd,
        output logic dmem_en, dmem_req,
        output logic [1: 0] dmem_size,     
        input logic dmem_addr_ok, dmem_data_ok,
        */
        output dbus_req_t  dmem_req,
        input dbus_resp_t dmem_resp,
        output dbus_req_t  imem_req,
        input dbus_resp_t imem_resp,
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
        output bpb_result_t destpc_commitC,
        //branch predict
        output logic jrp_reset,
        output logic [`JR_ENTRY_WIDTH - 1: 0] jrp_top,
        //to jr predict
        output rf_w_t [1: 0] cp0w,
		output creg_addr_t [1: 0] cp0_addrC,
		output logic [1: 0][2: 0] cp0_selC,
		input word_t [1: 0] cp0_dataC,
        //cp0 read/write
        output logic wait_ex, tlb_ex,
        output creg_addr_t [4: 0] reg_addrC,
        input word_t [4: 0] reg_dataC,
        input word_t [1: 0] hiloC,
        //delay execute
        output tu_op_req_t tu_op_req,
        input tu_op_resp_t tu_op_resp,
        output logic is_tlbr, 
        output logic is_tlbp,
		input logic tlb_free,
        //tlb
        input cp0_regs_t cp0_data,
        //cp0
		output logic [1: 0] icache_op
    );
    
    logic llwrite_ex;
    exec_data_t [1: 0] exception_out;
    exception_t exception_data_ex;
    logic exception_valid_ex, exception_valid_dt, finish_exception;
    logic dmem_en, dcache_en, icache_en;
	logic dmem_req_s, dcache_req_s, icache_req_s;
	word_t dmem_addr, dcache_addr, icache_addr;
    //logic [1: 0] dmem_size;
    exceptioncommit exceptioncommit(.clk, .reset, .flush(flushC), .stall(~finishC), .first_cycleC,
    								.mask(pc_mC),
									.in, .out(exception_out),
									.dmem_addr_ok(dmem_resp.addr_ok), 
									.dmem_req(dmem_req_s), 
									.dmem_wt(dmem_req.is_write), 
									.dmem_addr, 
									.dmem_wd(dmem_req.data),
									.dmem_write_en(dmem_req.write_en),
        							.dmem_en, .dmem_size(dmem_req.size), 
        							.ext_int,
        							.timer_interrupt,
        							.exception_valid(exception_valid_ex), .exception_data(exception_data_ex),
        							.bypass(bypass0),
        							.finish_exception,
        							.llwrite(llwrite_ex),
        							.llbit, .wait_ex,
        							.cp0_status(cp0_data.status), 
        							.cp0_cause(cp0_data.cause),
        							.cp0_entryhi(cp0_data.entryhi),
                                    .cp0_entrylo1(cp0_data.entrylo1), 
                                    .cp0_entrylo0(cp0_data.entrylo0),
                                    .cp0_index(cp0_data.index),
        							.tu_op_req, .tu_op_resp,
        							.is_tlbr, .is_tlbp,
        							.tlb_free,
									.dcache_addr_ok(dmem_resp.addr_ok),
									.dcache_func(dmem_req.cache_op.funct),
									.dcache_addr,
									.dcache_req(dcache_req_s), .dcache_en,
									.icache_addr_ok(imem_resp.addr_ok),
									.icache_func(imem_req.cache_op.funct),
									.icache_addr,
									.icache_req(icache_req_s), .icache_en);

	assign dmem_req.addr = (in[1].instr.ctl.cache_op.d_req | in[0].instr.ctl.cache_op.d_req) ? (dcache_addr) : (dmem_addr);
	assign imem_req.addr = icache_addr;
	
	assign imem_req.req = icache_req_s;
	assign imem_req.cache_op.req = icache_req_s;
	assign dmem_req.req = dcache_req_s | dmem_req_s;
	assign dmem_req.cache_op.req = dcache_req_s;

    assign cp0w[1].addr = exception_out[1].cp0_addr;
    assign cp0w[1].wd = exception_out[1].result;
    assign cp0w[1].wen = exception_out[1].instr.ctl.cp0write & finishC & ~pc_mC;
    assign cp0w[0].addr = exception_out[0].cp0_addr;
    assign cp0w[0].wd = exception_out[0].result;
    assign cp0w[0].wen = exception_out[0].instr.ctl.cp0write & finishC & ~pc_mC;    
	assign cp0_addrC = {exception_out[1].cp0_addr, exception_out[0].cp0_addr};
	assign cp0_selC = {exception_out[1].cp0_sel, exception_out[0].cp0_sel};
	
	word_t dmem_addr_dt, dmem_en_dt, dcache_en_dt, icache_en_dt;
	logic [1: 0] dmem_size_dt;
	exec_data_t [1: 0] cdata_in;
    exception_t exception_data_dt;
    word_t [1: 0] cp0_dataC_dt;
	
	logic llbit;
	always_ff @(posedge clk)
		begin
			if (~reset || exception_valid_dt)
				begin
					cdata_in <= '0;
					exception_data_dt <= '0;
					exception_valid_dt <= 1'b0;
					dmem_en_dt <= 1'b0;
					dmem_size_dt <= '0;
					dmem_addr_dt <= '0;
					cp0_dataC_dt <= '0;
					dcache_en_dt <= '0;
					icache_en_dt <= '0;
					llbit <= 1'b0;
				end
			else				
				if (finishC) 
					begin
						cdata_in <= exception_out;
						exception_data_dt <= exception_data_ex;
						exception_valid_dt <= exception_valid_ex;
						dmem_en_dt <= dmem_en;
						dmem_size_dt <= dmem_req.size;
						dmem_addr_dt <= dmem_req.addr;
						dcache_en_dt <= dcache_en;
						icache_en_dt <= icache_en;
						cp0_dataC_dt <= cp0_dataC;
						
						llbit <= llbit || llwrite_ex;
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
        				  .dmem_addr(dmem_addr_dt),
        				  .dmem_rd(dmem_resp.data),
        				  .dmem_data_ok(dmem_resp.data_ok),
        				  .finish_cdata,
        				  .cp0_epc(cp0_data.epc),
        				  .reg_addrC, .reg_dataC, .hiloC,
						  //.cp0_addrC, 
						  .cp0_dataC(cp0_dataC_dt),
						  .tlb_ex,
						  .dcache_en(dcache_en_dt),
						  .icache_en(icache_en_dt),
						  .dcache_data_ok(dmem_resp.data_ok),
						  .icache_data_ok(imem_resp.data_ok));
	
	assign finishC = finish_exception & finish_cdata;   
	assign exception_valid = exception_valid_dt;	
	assign pc_mC = fetch.branch | fetch.jump | fetch.jr | fetch.exception_valid | fetch.is_eret | fetch.tlb_ex;
	assign is_eret = fetch.is_eret;						

    assign jrp_reset = pc_mC;
    assign jrp_top = cdata_in[1].jrtop;
    
	assign icache_op = {icache_en, icache_en_dt};
           
endmodule