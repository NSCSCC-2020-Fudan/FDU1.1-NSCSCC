`include "mips.svh"

module signaldecode (
        input fetch_data_t dataF,
        output decode_data_t dataD
        //input cp0_status_t cp0_status,
        //input cp0_status_t cp0_cause
    );
	op_t op;
	func_t func;
	halfword_t imm;
	logic ext;
	word_t pcbranch, pcjump;
	word_t hi, lo;
	word_t aluoutM, resultW;
	logic is_reserved;
	creg_addr_t rs, rt, rd;
    assign op = dataF.instr_[31:26];
	assign func = dataF.instr_[5:0];
	assign imm = dataF.instr_[15:0];
	assign rs = dataF.instr_[25:21];
	assign rt = dataF.instr_[20:16];
	assign rd = dataF.instr_[15:11];
	// assign dataD.instr.rs = dataF.instr_[25:21];
	// assign dataD.instr.rt = dataF.instr_[20:16];
	// assign dataD.instr.rd = dataF.instr_[15:11];
    
	maindecode maindecode(dataF.instr_,
	                      rs, rt, rd, 
	                      dataD.instr.op, dataD.exception_ri, 
	                      dataD.instr.ctl, 
	                      dataD.srcrega, dataD.srcregb, dataD.destreg);
    assign dataD.cp0_addr = rd;	                      

	assign dataD.instr.shamt = dataF.instr_[10:6];
	assign is_reserved = (dataD.instr.op == RESERVED);
	
	word_t ext_imm, pc_imm;
	extend ext1(imm, dataD.instr.ctl.zeroext, ext_imm);
	assign pcbranch = dataF.pcplus4 + {dataD.instr.extended_imm[29:0], 2'b00};
	assign pcjump = {dataF.pcplus4[31:28], dataF.instr_[25:0], 2'b00};
	assign pc_imm = (dataD.instr.ctl.branch) ? (pcbranch) : (pcjump);
	assign dataD.instr.pcbranch = pcbranch;
	assign dataD.instr.extended_imm = ext_imm;
	assign dataD.instr.pcjump = pcjump;
	assign dataD.pred = dataF.pred;
    
	assign dataD.pcplus4 = dataF.pcplus4;
	assign dataD.exception_instr = dataF.exception_instr;
/*
	srcadmux srcadmux(.regfile(regfile.src1),.m(hazard.aluoutM),.w(hazard.resultW),.alusrcaE(hazard.alusrcaE),
					  .forward(hazard.forwardAD), .ctl(dataD.instr.ctl), 
					  .hiD(hilo.hi), .loD(hilo.lo), .cp0D(cp0.rd),
					  .srca(dataD.srca));
	srcbdmux srcbdmux(.regfile(regfile.src2),.m(hazard.aluoutM),.w(hazard.resultW),.alusrcaE(hazard.alusrcaE),
					  .forward(hazard.forwardBD), .srcb(dataD.srcb));
*/

	assign dataD.in_delay_slot = 1'b0; //dataF.in_delay_slot;
	// assign dataD.en = dataF.en;
	// ports

	//assign dataD.cp0_cause = cp0_cause;
    //assign dataD.cp0_status = cp0_status;
endmodule