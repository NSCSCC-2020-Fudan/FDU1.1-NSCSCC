`include "mips.svh"
module execute (
    decode_ereg_exec.exec in,
    exec_mreg_memory.exec out,
    hazard_intf.exec hazard
);
    word_t alusrcaE, alusrcbE, writedataE;
    exec_data_t dataE;
    decode_data_t dataD;
    word_t srcaE, srcbE;
    word_t aluoutM, resultW;
    creg_addr_t writeregE;
    forward_t forwardAE, forwardBE;
    word_t aluoutE;
    logic exception_of;
    word_t hi, lo;
    wrmux wrmux0(.rt(dataD.instr.rt), .rd(dataD.instr.rd), 
                 .jump(dataD.instr.ctl.jump), .regdst(dataD.instr.ctl.regdst), 
                 .writereg(writeregE));
    srcaemux srcaemux(.e(srcaE),.m(aluoutM),.w(resultW),.sel(forwardAE),.srca(alusrcaE));
    wdmux wdmux(.e(dataD.srcb),.m(aluoutM),.w(resultW),.sel(forwardBE),.srcb0);
    srcbemux srcbemux(.srcb0,.imm(dataD.instr.extended_imm),.shamt(dataD.instr.shamt),.srcb);
    alu alu(alusrca, alusrcb, dataD.instr.ctl.alufunc, aluoutE, exception_of);
    mult multdiv(.a(srca), .b(srcb), .op(dataD.instr.op), .hi(hi), .lo(lo));

// typedef struct packed {
//     decoded_instr_t instr;
//     logic exception_instr, exception_ri, exception_of;
//     word_t aluout;
//     creg_addr_t writereg;
//     word_t writedata;
//     word_t hi, lo;
//     word_t pcplus4;
// } exec_data_t;
    assign dataE = {
        dataD.instr,
        dataD.exception_instr, dataD.exception_ri, exception_of,
        aluoutE,
        writeregE,
        writedataE,
        hi, lo,
        dataD.pcplus4
    };
    
    // ports
    // decode_ereg_exec.exec in
    assign dataD = in.dataD;

    // exec_mreg_memory.exec out
    assign out = dataE;
    
    // hazard_intf.exec hazard
    assign hazard.dataE = dataE;
    assign forwardAE = hazard.forwardAE;
    assign forwardBE = hazard.forwardBE;
    assign aluoutM = hazard.aluoutM;
    assign resultW = hazard.resultW;
endmodule