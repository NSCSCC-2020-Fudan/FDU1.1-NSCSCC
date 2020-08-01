module arf 
	import common::*;
	import regfile_pkg::*;
	(
	input logic clk, resetn,
	retire_intf.arf retire,
	output rf_w_t [AREG_WRITE_PORTS-1:0]rfwrite,
	payloadRAM_intf.arf payloadRAM
);
    word_t[AREG_NUM-1:0] regfile, regfile_new;
	read_req_t [AREG_READ_PORTS-1:0]reads;
	write_req_t [AREG_WRITE_PORTS-1:0]writes;
	read_resp_t [AREG_READ_PORTS-1:0]read_resps;
	// write
	always_comb begin
		regfile_new = regfile;
		for (int i=1; i<AREG_NUM; i++) begin
			for (int j=0; j<AREG_WRITE_PORTS; j++) begin
				if (writes[j].valid && writes[j].id == i) begin
					regfile_new[i] = writes[j].data;
				end
			end	
		end
	end

	// read		
	for (genvar i=0; i<AREG_READ_PORTS; i++) 
		assign read_resps[i].data = reads[i].mode == READ_FIRST ? 
									  regfile[reads[i].id] : regfile_new[reads[i].id];
	
	always_ff @(posedge clk) begin
		if (~resetn) begin
			regfile <= '0;
		end else begin
			regfile <= regfile_new;
		end
	end

	// self
	for (genvar i = 0; i < AREG_READ_PORTS ; i++) begin
		assign payloadRAM.arf1[i] = regfile_new[payloadRAM.creg1[i][4:0]];
		assign payloadRAM.arf2[i] = regfile_new[payloadRAM.creg2[i][4:0]];
	end
	for (genvar i = 0; i < AREG_WRITE_PORTS ; i++) begin
		assign writes[i].valid = retire.retire[i].ctl.regwrite;
		assign writes[i].id = retire.retire[i].dst;
		assign writes[i].data = retire.retire[i].data.data;
		assign rfwrite[i].wen = writes[i].valid;
		assign rfwrite[i].addr = writes[i].id;
		assign rfwrite[i].wd = writes[i].data;
	end
endmodule