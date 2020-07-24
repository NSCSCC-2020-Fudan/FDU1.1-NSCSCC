`include "mips.svh"

module signalcommit (
        input exec_data_t dataE,
        output exec_data_t dataM,
        output m_q_t mem
        // output bypass_t forward,
        // output exception_set_t exception,
        // output dmem_t dram_req,
        // input word_t readdata,
        // output cp0_commit_t cp0,
        // output logic is_eret
    );
    
    logic wen, ren;
    word_t aluoutM, writedataM;
    decoded_op_t op;
    assign op = dataE.instr.op;
    assign aluoutM = dataE.result;
    assign ren = {4{dataE.instr.ctl.memtoreg}};
    
    writedata_format writedata_format(.addr(aluoutM[1:0]), .op(op), ._wd(dataE.writedata), .en(wen), .wd(writedataM));
    
    assign dataM = dataE;
    assign mem.ren = ren;
    assign mem.addr = aluoutM;
    assign mem.wen = wen;
    assign mem.addr = aluoutM;
    assign mem.wd = writedataM;
    assign mem.wt = dataE.instr.clt.memwrite;

endmodule