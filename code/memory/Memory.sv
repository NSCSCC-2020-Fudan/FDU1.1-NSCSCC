`include "mips.svh"

module memory (
    exec_mreg_memory.memory in,
    memory_wreg_writeback.memory out,
    hazard_intf.memory hazard,
    exception_intf.memory exception,
    memory_dram.memory dram
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
    logic exception_data;
    rwen_t ren, wen;
    assign exception_data = ((op == SW || op == LW) && (aluoutM[1:0] != '0)) ||
                            ((op == SH || op == LH || op == LHU) && (aluoutM[0] != '0));
    writedata writedata(.addr(aluoutM[1:0]), .op(op), ._wd(dataE.writedata),.en(wen), .wd(writedataM));
    readdata readdata(._rd(dram.rd), .op(op), .addr(aluoutM[1:0]), .rd(readdataM));
    assign ren = {4{dataE.instr.ctl.memread}};
    assign mread = {
        ren,
        aluoutM
    };
    assign mwrite = {
        wen,
        aluoutM,
        writedataM
    };
// typedef struct packed {
//     decoded_instr_t instr;
//     word_t rd, aluout;
//     creg_addr_t writereg;
//     word_t hi, lo;
//     word_t pcplus4;
// } mem_data_t;    
    assign dataM = {
        dataE.instr,
        readdataM, aluoutM,
        dataE.writereg,
        dataE.hi, dataE.lo,
        dataE.pcplus4
    };
    // ports
    // exec_mreg_memory.memory in
    assign dataE = in.dataE;

    // memory_wreg_writeback.memory out
    assign out.dataM_new = dataM;

    // hazard_intf.memory hazard
    assign hazard.dataM = dataM;
    // exception_intf.memory exception

    // memory_dram.memory dram    
    assign dram.mread = mread;
    assign dram.mwrite = mwrite;
    
endmodule