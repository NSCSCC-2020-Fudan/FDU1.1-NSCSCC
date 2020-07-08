`include "mips.svh"

module writeback (
    memory_wreg_writeback.writeback in,
    regfile_intf.writeback regfile,
	hilo_intf.writeback hilo,
	cp0_intf.writeback cp0,
	hazard_intf.writeback hazard
    output word_t pc
);
    decoded_op_t op;
    assign op = in.dataM.decoded_instr.op;
    assign result = in.dataM.decoded_instr.ctl.memread ? dataM.rd : dataM.aluout;
    assign pc = in.dataM.decoded_instr.pcplus4 - 32'd4;

    assign regfile.rfwrite.wen = in.dataM.decoded_instr.ctl.regwrite;
    assign regfile.rfwrite.addr = in.dataM.writereg;
    assign regfile.rfwrite.wd = result;

    assign hilo.wen_h = (op == MTHI) || (op == MULT) || (op == MULTU) || (op == DIV) || (op == DIVU);
    assign hilo.wen_l = (op == MTLO) || (op == MULT) || (op == MULTU) || (op == DIV) || (op == DIVU);
    assign hilo.wd_h = (op == MTHI) ? result : in.dataM.hi;
    assign hilo.wd_l = (op == MTLO) ? result : in.dataM.lo;

    assign hazard.dataW.decoded_instr = in.dataM.decoded_instr;
    assign hazard.resultW = result;
    assign hazard.dataW.writereg = in.dataM.writereg;
endmodule