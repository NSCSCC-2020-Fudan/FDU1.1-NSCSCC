`include "mips.svh"

module decode (
    // input word_t instr,
    // inout fetch_data_t dataF,
	// output dataD_t dataD,
	// output word_t pcbranch, pcjump,
	// output branch_taken,
	// input word_t srca0, srcb0
	fetch_dreg_decode.decode in,
	decode_ereg_exec.decode out,
	regfile_intf.decode regfile,
	hilo_intf.decode hilo,
	cp0_intf.decode cp0,
	hazard_intf.decode hazard,
	pcselect_intf.decode pcselect
);
	op_t op;
	func_t func;
	halfword_t imm;
	decode_data_t dataD;
	fetch_data_t dataF;
	logic ext;
	word_t hi, lo;
	word_t aluoutM, resultW;
	forward_t forwardAD, forwardBD;
    assign op = dataF.instr_[31:26];
	assign func = dataF.instr_[5:0];
	assign imm = dataF.instr_[15:0];
	assign dataD.instr.rs = dataF.instr_[25:21];
	assign dataD.instr.rt = dataF.instr_[20:16];
	assign dataD.instr.rd = dataF.instr_[15:11];
	assign dataD.instr.shamt = dataF.instr_[15:11];
	assign ext = (dataD.instr.op == AND) || (dataD.instr.op == NOR) || (dataD.instr.op == OR) || (dataD.instr.op == XOR);
	extend ext1(imm, ext, dataD.instr.extended_imm);
	assign dataD.instr.ctl.alusrc = (op == `OP_RT) ? REG : IMM;
	assign dataD.instr.ctl.regwrite = (dataD.instr.op == BGEZAL) || (dataD.instr.op == BLTZAL) ||
							 (dataD.instr.op == SB) || (dataD.instr.op == SH) ||
							 (dataD.instr.op == SW) || (dataD.instr.op == MFC0) ||
							 (dataD.instr.op == ADD) || (dataD.instr.op == ADDU) ||
							 (dataD.instr.op == SUB) || (dataD.instr.op == SUBU) ||
							 (dataD.instr.op == SLT) || (dataD.instr.op == SLTU) ||
							 (dataD.instr.op == AND) || (dataD.instr.op == NOR) ||
							 (dataD.instr.op == OR) || (dataD.instr.op == XOR) ||
							 (dataD.instr.op == SLLV) || (dataD.instr.op == SLL) ||
							 (dataD.instr.op == SRAV) || (dataD.instr.op == SRA) ||
							 (dataD.instr.op == SRLV) || (dataD.instr.op == SRL) ||
							 (dataD.instr.op == JAL) || (dataD.instr.op == JALR) ||
							 (dataD.instr.op == MFHI) || (dataD.instr.op == MFLO);
	assign dataD.instr.ctl.memread = (dataD.instr.op == LB) || (dataD.instr.op == LBU) ||
							(dataD.instr.op == LH) || (dataD.instr.op == LHU) ||
							(dataD.instr.op == LW);
	assign dataD.instr.ctl.memwrite = (dataD.instr.op == SB) || (dataD.instr.op == SW) || (dataD.instr.op == SH);
	assign dataD.instr.ctl.regdst = (op == `OP_RT) ? RD : RT;
	assign dataD.instr.ctl.branch = (dataD.instr.op == BEQ) || (dataD.instr.op == BNE) || 
						   (dataD.instr.op == BGEZ) || (dataD.instr.op == BGTZ) ||
						   (dataD.instr.op == BLEZ) || (dataD.instr.op == BLTZ) ||
						   (dataD.instr.op == BGEZAL) || (dataD.instr.op == BLTZAL);

	assign dataD.instr.ctl.jump = (dataD.instr.op == J) || (dataD.instr.op == JAL) || (dataD.instr.op == JALR) || (dataD.instr.op == JR);
	assign dataD.instr.ctl.jr = (dataD.instr.op == JALR) || (dataD.instr.op == JR);
	assign dataD.instr.ctl.shift = (dataD.instr.op == SLLV) || (dataD.instr.op == SLL) ||
						  (dataD.instr.op == SRAV) || (dataD.instr.op == SRA) ||
						  (dataD.instr.op == SRLV) || (dataD.instr.op == SRL) ||
						  (dataD.instr.op == LUI);
	maindec mainde(dataF.instr, dataD.instr.op, dataD.exception_ri);
	aludec alude(dataD.instr.op, dataD.instr.ctl.alufunc);

	assign pcbranch = dataF.pcplus4 + {dataD.instr.extended_imm[29:0], 2'b00};
	assign pcjump = {dataF.pcplus4[31:28], dataF.instr_[25:0], 2'b00};
	assign branch_taken = dataD.instr.ctl.branch && (
		((dataD.srca == dataD.srcb) && (dataD.instr.op == BEQ)) ||
		((dataD.srca != dataD.srcb) && (dataD.instr.op == BNE)) ||
		((dataD.srca[31] == 0) && (dataD.instr.op == BGEZ)) ||
		((dataD.srca[31] == 1'b0 && dataD.srca != '0) && (dataD.instr.op == BGTZ)) ||
		((dataD.srca[31] == 1'b1 || dataD.srca == '0) && (dataD.instr.op == BLEZ)) ||
		((dataD.srca[31] == 1'b1) && (dataD.instr.op == BLTZ)) ||
		((dataD.srca[31] == 1'b0) && (dataD.instr.op == BGEZAL)) ||
		((dataD.srca[31] == 1'b1) && (dataD.instr.op == BLTZAL))
	);

	assign dataD.pcplus4 = dataF.pcplus4;
	assign dataD.exception_instr = dataF.exception_instr;

	srcadmux srcadmux(.regfile(regfile.src1),.m(hazard.aluoutM),.w(hazard.resultW),.sel(hazard.forwardAD),.srca(dataD.srca));
	srcbdmux srcbdmux(.regfile(regfile.src2),.m(hazard.aluoutM),.w(hazard.resultW),.sel(hazard.forwardBD),.srcb(dataD.srcb));

	// ports
	// 	fetch_dreg_decode.decode in
	assign dataF = in.dataF;

	// decode_ereg_exec.decode out
	assign out.dataD_new = dataD;

	// regfile_intf.decode regfile
	assign regfile.ra1 = dataD.instr.rs;
	assign regfile.ra2 = dataD.instr.rt;

	// hilo_intf.decode hilo
	assign hi = hilo.hi;
	assign lo = hilo.lo;

	// cp0_intf.decode cp0

	// hazard_intf.decode hazard
	assign hazard.dataD = dataD;
	assign forwardAD = hazard.forwardAD;
	assign forwardBD = hazard.forwardBD;
	assign aluoutM = hazard.aluoutM;
	assign resultW = hazard.resultW;

	// pcselect_intf.decode pcselect
	assign pcselect.pcbranchD = pcbranch;
	assign pcselect.pcjumpD = pcjump;
	assign pcselect.pcjrD = dataD.srca;
	assign pcselect.branch_taken = branch_taken;
	assign pcselect.jr = dataD.instr.ctl.jr;
	assign pcselect.jump = dataD.instr.ctl.jump;
endmodule