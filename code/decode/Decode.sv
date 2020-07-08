`include "mips.svh"

module decode_ (
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
    assign op = in.dataF.instr[31:26];

    func_t func;
	assign func = in.dataF.instr[5:0];
	
	halfword_t imm;
	assign imm = in.dataF.instr[15:0];
	decoded_instr_t di;
	assign di.rs = in.dataF.instr[25:21];
	assign di.rt = in.dataF.instr[20:16];
	assign di.rd = in.dataF.instr[15:11];
	assign di.shamt = in.dataF.instr[15:11];
	assign di.ctl.alusrc = (op == `OP_RT) ? REG : IMM;
	assign di.ctl.regwrite = (di.op == BGEZAL) || (di.op == BLTZAL) ||
							 (di.op == SB) || (di.op == SH) ||
							 (di.op == SW) || (di.op == MFC0) ||
							 (di.op == ADD) || (di.op == ADDU) ||
							 (di.op == SUB) || (di.op == SUBU) ||
							 (di.op == SLT) || (di.op == SLTU) ||
							 (di.op == AND) || (di.op == NOR) ||
							 (di.op == OR) || (di.op == XOR) ||
							 (di.op == SLLV) || (di.op == SLL) ||
							 (di.op == SRAV) || (di.op == SRA) ||
							 (di.op == SRLV) || (di.op == SRL) ||
							 (di.op == JAL) || (di.op == JALR) ||
							 (di.op == MFHI) || (di.op == MFLO);
	assign di.ctl.memread = (di.op == LB) || (di.op == LBU) ||
							(di.op == LH) || (di.op == LHU) ||
							(di.op == LW);
	assign di.ctl.memwrite = (di.op == SB) || (di.op == SW) || (di.op == SH);
	assign di.ctl.regdst = (op == `OP_RT) ? RD : RT;
	assign di.ctl.branch = (di.op == BEQ) || (di.op == BNE) || 
						   (di.op == BGEZ) || (di.op == BGTZ) ||
						   (di.op == BLEZ) || (di.op == BLTZ) ||
						   (di.op == BGEZAL) || (di.op == BLTZAL);

	assign di.ctl.jump = (di.op == J) || (di.op == JAL) || (di.op == JALR) || (di.op == JR);
	assign di.ctl.jr = (di.op == JALR) || (di.op == JR);
	assign di.ctl.shift = (di.op == SLLV) || (di.op == SLL) ||
						  (di.op == SRAV) || (di.op == SRA) ||
						  (di.op == SRLV) || (di.op == SRL) ||
						  (di.op == LUI);
	maindec mainde(in.dataF.instr, di.op, out.dataD_new.exception_ri);
	aludec alude(di.op, di.ctl.alufunc);
	
	logic ext = (di.op == AND) || (di.op == NOR) || (di.op == OR) || (di.op == XOR);
	extend ext1(imm, ext, di.extended_imm);

	assign pcbranch = in.dataF.pcplus4 + {di.extended_imm[29:0], 2'b00};
	assign pcjump = {in.dataF.pcplus4[31:28], in.dataF.instr[25:0], 2'b00};
	assign branch_taken = di.ctl.branch && (
		((out.dataD_new.srca == out.dataD_new.srcb) && (di.op == BEQ)) ||
		((out.dataD_new.srca != out.dataD_new.srcb) && (di.op == BNE)) ||
		((out.dataD_new.srca[31] == 0) && (di.op == BGEZ)) ||
		((out.dataD_new.srca[31] == 1'b0 && out.dataD_new.srca != '0) && (di.op == BGTZ)) ||
		((out.dataD_new.srca[31] == 1'b1 || out.dataD_new.srca == '0) && (di.op == BLEZ)) ||
		((out.dataD_new.srca[31] == 1'b1) && (di.op == BLTZ)) ||
		((out.dataD_new.srca[31] == 1'b0) && (di.op == BGEZAL)) ||
		((out.dataD_new.srca[31] == 1'b1) && (di.op == BLTZAL))
	);
	assign out.dataD_new.decoded_instr = di;
	assign out.dataD_new.pcplus4 = in.dataF.pcplus4;
	assign out.dataD_new.exception_instr = in.dataF.exception_instr;

	assign regfile.ra1 = di.rs;
	assign regfile.ra2 = di.rt;

	assign hazard.dataD = out.dataD_new;
	assign pcselect.pcbranchD = pcbranch;
	assign pcselect.pcjumpD = pcjump;
	assign pcselect.pcjrD = out.dataD_new.srca;
	assign pcselect.branch_taken = branch_taken;
	assign pcselect.jr = di.ctl.jr;
	assign pcselect.jump = di.ctl.jump;
	srcadmux srcadmux(.regfile(regfile.src1),.m(hazard.aluoutM),.w(hazard.resultW),.sel(hazard.forwardAD),.srca(out.dataD_new.srca));
	srcbdmux srcbdmux(.regfile(regfile.src2),.m(hazard.aluoutM),.w(hazard.resultW),.sel(hazard.forwardBD),.srcb(out.dataD_new.srcb));
endmodule