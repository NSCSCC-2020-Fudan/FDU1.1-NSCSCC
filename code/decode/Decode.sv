`include "mips.svh"

module decode (
    input word_t instr,
    inout word_t pcplus4,
    output decoded_instr_t di
);
    op_t op;
    assign op = instr[31:26];

    func_t func;
    assign func = instr[5:0];

	assign di.rs = instr[25:21];
	assign di.rt = instr[20:16];
	assign di.rd = instr[15:11];
	assign di.shamt = instr[15:11];
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

	maindec mainde(instr, di.op);
    aludec alude(di.op, di.ctl.alufunc);
    
endmodule



