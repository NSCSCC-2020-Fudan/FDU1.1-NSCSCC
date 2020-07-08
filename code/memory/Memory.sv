`include "mips.svh"

module memory_ (
    exec_mreg_memory.memory in,
    memory_wreg_writeback.memory out,
    hazard_intf.memory hazard,
    exception_intf.memory exception,
    memory_dram.memory dram
);
    // assign mread.en = dataE.memread;
    assign dram.mread.addr = in.dataE.aluout;
    // assign mwrite.en = dataE.memwrite;
    assign dram.mwrite.addr = in.dataE.aluout;
    decoded_op_t op;
    assign op = in.dataE.decoded_instr.op;
    logic exception_data;
    assign exception_data = ((op == SW || op == LW) && (in.dataE.aluout[1:0] != '0)) ||
                            ((op == SH || op == LH || op == LHU) && (in.dataE.aluout[0] != '0));
    writedata writedata(.addr(in.dataE.aluout[1:0]), .op(op), ._wd(in.dataE.writedata),.en(dram.mwrite.wen), .wd(dram.mwrite.wd));
    readdata readdata(._rd(dram.rd), .op(op), .rd(out.dataM_new.rd));
    assign out.dataM_new.writereg = in.dataE.writereg;
    assign out.dataM_new.pcplus4 = in.dataE.pcplus4;
    assign hazard.dataM = out.dataM_new;
endmodule