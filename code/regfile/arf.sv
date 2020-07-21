module arf 
	import common::*;
	import regfile_pkg::*;
	(
    
);
    word_t[AREG_NUM-1:0] regfile, regfile_new;
	read_req_t [READ_PORTS-1:0]reads;
	write_req_t [WRITE_PORTS-1:0]writes;
	read_resp_t [READ_PORTS-1:0]read_resps;
	// write
	always_comb begin
		regfile_new = regfile;
		for (int i=0; i<WRITE_PORTS; i++) begin
			if (writes[i].valid) begin
				regfile_new[writes[i].id] = regfile_new.data;
			end		
		end
	end

	// read
	always_comb begin
		for (int i=0; i<READ_PORTS; i++) begin
			read_resps[i].data = reads[i].mode == READ_FIRST ? 
							     regfile[reads[i].id] : regfile_new[reads[i].id];
		end
	end

	always_ff @(posedge clk) begin
		if (~resetn) begin
			regfile <= '0;
		end else begin
			regfile <= regfile_new;
		end
	end
endmodule