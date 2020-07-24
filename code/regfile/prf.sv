module prf 
	import common::*;
	import regfile_pkg::*;
	(
    
);
    word_t[PREG_NUM-1:0] regfile, regfile_new;
	read_req_t [PREG_READ_PORTS-1:0]reads;
	write_req_t [PREG_WRITE_PORTS-1:0]writes;
	read_resp_t [PREG_READ_PORTS-1:0]read_resps;
	// write
	always_comb begin
		regfile_new = regfile;
		for (int i=1; i<PREG_NUM; i++) begin
			for (int j=0; j<PREG_WRITE_PORTS; j++) begin
				if (writes[j].valid && writes[j].id == i) begin
					regfile_new[i] = writes[j].data;
				end
			end	
		end
	end

	// read		
	for (genvar i=0; i<PREG_READ_PORTS; i++) 
		assign read_resps[i].data = reads[i].mode == READ_FIRST ? 
									  regfile[reads[i].id] : regfile_new[reads[i].id];
	
	always_ff @(posedge clk) begin
		if (~resetn) begin
			regfile <= '0;
		end else begin
			regfile <= regfile_new;
		end
	end
endmodule