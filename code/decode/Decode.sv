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
	assign di.ctl.alusrc = (op == `OP_RT) ? REG : IMM;
	assign di.ctl.regwrite = (op == `OP_RT) ? 1'b1 : 1'b0;
	assign di.ctl.memread = (di.op == LB) || (di.op == LBU) ||
							(di.op == LH) || (di.op == LHU) ||
							(di.op == LW) ||
							(di.op == SB) || (di.op == SH);
	assign di.ctl.memwrite = (di.op == SB) || (di.op == SW) || (di.op == SH);


	maindec mainde(instr, di.op);
    aludec alude(di.op, di.ctl.alufunc);
    
endmodule



