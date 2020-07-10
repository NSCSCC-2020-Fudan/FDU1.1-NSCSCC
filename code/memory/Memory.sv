`include "mips.svh"

module memory (
    exec_mreg_memory.memory in,
    memory_wreg_writeback.memory out,
    hazard_intf.memory hazard,
    exception_intf.memory exception,
    memory_dram.memory dram,
    cp0_intf.memory cp0
);
    word_t aluoutM, writedataM, readdataM;
    exec_data_t dataE;
    mem_data_t dataM;
    m_r_t mread;
    m_w_t mwrite;
    assign aluoutM = dataE.aluout;
    // assign mwrite.en = dataE.memwrite;
    assign dram.mwrite.addr = dataE.aluout;
    decoded_op_t op;
    assign op = dataE.instr.op;
    logic exception_data, exception_sys, exception_bp;
    rwen_t ren, wen;
    assign exception_data = ((op == SW || op == LW) && (aluoutM[1:0] != '0)) ||
                            ((op == SH || op == LH || op == LHU) && (aluoutM[0] != '0));
    assign exception_sys = (dataE.instr.op == SYSCALL);
    assign exception_bp = (dataE.instr.op == BREAK);
    writedata writedata(.addr(aluoutM[1:0]), .op(op), ._wd(dataE.writedata),.en(wen), .wd(writedataM));
    // readdata readdata(._rd(dram.rd), .op(op), .addr(aluoutM[1:0]), .rd(readdataM));
    assign ren = {4{dataE.instr.ctl.memread}};
    assign mread.ren = ren;
    assign mread.addr = aluoutM;
    assign mwrite.wen = wen;
    assign mwrite.addr = aluoutM;
    assign mwrite.wd = writedataM;
// typedef struct packed {
//     decoded_instr_t instr;
//     word_t rd, aluout;
//     creg_addr_t writereg;
//     word_t hi, lo;
//     word_t pcplus4;
// } mem_data_t;    
    assign dataM.instr = dataE.instr;
    // assign dataM.rd = readdataM;
    assign dataM.aluout = aluoutM;
    assign dataM.writereg = dataE.writereg;
    assign dataM.hi = dataE.hi;
    assign dataM.lo = dataE.lo;
    assign dataM.pcplus4 = dataE.pcplus4;
    // ports
    // exec_mreg_memory.memory in
    assign dataE = in.dataE;

    // memory_wreg_writeback.memory out
    assign out.dataM_new = dataM;

    // hazard_intf.memory hazard
    assign hazard.dataM = dataM;
    // exception_intf.memory exception
    assign exception.exception_instr = dataE.exception_instr;
    assign exception.exception_ri =  dataE.exception_ri;
    assign exception.exception_of = dataE.exception_of;
    assign exception.exception_data = exception_data;
    assign exception.exception_sys = exception_sys;
    assign exception.exception_bp = exception_bp;
    assign exception.in_delay_slot = dataE.instr.ctl.branch | dataE.instr.ctl.jump;// wrong
    assign exception.pc = dataE.pcplus4 - 32'd4;
    assign exception.vaddr = aluoutM;
    assign exception.interrupt_info = ({exception.ext_int, 2'b00} | cp0.cp0_data.cause.IP) & cp0.cp0_data.status.IM;
    // memory_dram.memory dram    
    assign dram.mread = mread;
    assign dram.mwrite = mwrite;
    // cp0
    assign cp0.is_eret = (dataE.instr.op == ERET);
endmodule