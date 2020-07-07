`include "mips.svh"

module decode (
    input word_t instr,
    inout fetch_data_t dataF,
	output dataD_t dataD,
	output word_t pcbranch, pcjump,
	output branch_taken,
	input word_t srca0, srcb0
);
    op_t op;
    assign op = dataF.instr[31:26];

    func_t func;
	assign func = dataF.instr[5:0];
	
	halfword_t imm;
	assign imm = dataF.instr[15:0];
	decoded_instr_t di;
	assign di.rs = dataF.instr[25:21];
	assign di.rt = dataF.instr[20:16];
	assign di.rd = dataF.instr[15:11];
	assign di.shamt = dataF.instr[15:11];
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
							(di.op == LW) ||
							(di.op == SB) || (di.op == SH);
	assign di.ctl.memwrite = (di.op == SB) || (di.op == SW) || (di.op == SH);
	assign di.ctl.regdst = (op == `OP_RT) ? 1'b1 : 1'b0;
	assign di.ctl.branch = (di.op == BEQ) || (di.op == BNE) || 
						   (di.op == BGEZ) || (di.op == BGTZ) ||
						   (di.op == BLEZ) || (di.op == BLTZ) ||
						   (di.op == BGEZAL) || (di.op == BLTZAL);

	assign di.ctl.jump = (di.op == J) || (di.op == JAL) || (di.op == JALR) || (di.op == JR);
	maindec mainde(instr, di.op, dataD.exception_ri);
	aludec alude(di.op, di.ctl.alufunc);
	
	logic ext = (di.op == AND) || (di.op == NOR) || (di.op == OR) || (di.op == XOR);
	extend ext1(imm, ext, di.extended_imm);

	assign pcbranch = dataF.pcplus4 + {di.extended_imm[29:0], 2'b00};
	assign pcjump = {dataF.pcplus4[31:28], dataF.instr[25:0], 2'b00};
	assign branch_taken = di.ctl.branch && (
		((di.srca == di.srcb) && (di.op == BEQ)) ||
		((di.srca != di.srcb) && (di.op == BNE)) ||
		((di.srca[31] == 0) && (di.op == BGEZ)) ||
		((di.srca[31] == 1'b0 && di.srca != '0) && (di.op == BGTZ)) ||
		((di.srca[31] == 1'b1 || di.srca == '0) && (di.op == BLEZ)) ||
		((di.srca[31] == 1'b1) && (di.op == BLTZ)) ||
		((di.srca[31] == 1'b0) && (di.op == BGEZAL)) ||
		((di.srca[31] == 1'b1) && (di.op == BLTZAL))
	);

	assign dataD.decoded_instr = di;
	assign dataD.pcplus4 = dataF.pcplus4;
	assign dataD.exception_instr = dataF.exception_instr;
endmodule