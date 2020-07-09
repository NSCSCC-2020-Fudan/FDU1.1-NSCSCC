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
    word_t aluoutE, aluoutE0;
    logic exception_of;
    word_t hi, lo;
    logic jumpE; 
    regdst_t regdstE;
    creg_addr_t rtE, rdE;
    word_t shamt, imm;
    alufunc_t alufuncE;
    decoded_op_t op;
    word_t pcplus4E;
    decoded_instr_t instrE;
    wrmux wrmux0(.rt(rtE), .rd(rdE), 
                 .jump(jumpE), .regdst(regdstE), 
                 .writereg(writeregE));
    srcaemux srcaemux(.e(srcaE),.m(aluoutM),.w(resultW),.forward(forwardAE),.alusrca(alusrcaE));
    wdmux wdmux(.e(srcbE),.m(aluoutM),.w(resultW),.forward(forwardBE),.wd(writedataE));
    srcbemux srcbemux(.wd(writedataE), .imm(imm),.shamt(shamt),.instr(instrE),.alusrcb(alusrcbE));
    alu alu(alusrcaE, alusrcbE, alufuncE, aluoutE0, exception_of);
    mult multdiv(.a(alusrcaE), .b(alusrcbE), .op(op), .hi(hi), .lo(lo));
    aluoutmux aluoutmux(.aluout(aluoutE0), .pcplus8(pcplus4E + 32'd4), .jump(jumpE), .out(aluoutE));

    assign srcaE = dataD.srca;
    assign srcbE = dataD.srcb;
    assign aluoutM = hazard.aluoutM;
    assign resultW = hazard.resultW;
    assign forwardAE = hazard.forwardAE;
    assign forwardBE = hazard.forwardBE;
    assign jumpE = dataD.instr.ctl.jr | dataD.instr.ctl.branch;
    assign regdstE = dataD.instr.ctl.regdst;
    assign rtE = dataD.instr.rt;
    assign rdE = dataD.instr.rd;
    assign shamt = {27'b0,dataD.instr.shamt};
    assign imm = dataD.instr.extended_imm;
    assign alufuncE = dataD.instr.ctl.alufunc;
    assign op = dataD.instr.op;
    assign pcplus4E = dataD.pcplus4;
    assign instrE = dataD.instr;
    // typedef struct packed {
//     decoded_instr_t instr;
//     logic exception_instr, exception_ri, exception_of;
//     word_t aluout;
//     creg_addr_t writereg;
//     word_t writedata;
//     word_t hi, lo;
//     word_t pcplus4;
// } exec_data_t;
    assign dataE.instr = dataD.instr;
    assign dataE.exception_instr = dataD.exception_instr;
    assign dataE.exception_ri = dataD.exception_ri;
    assign dataE.exception_of = exception_of;
    assign dataE.aluout = aluoutE;
    assign dataE.writereg = writeregE;
    assign dataE.writedata = writedataE;
    assign dataE.hi = hi;
    assign dataE.lo = lo;;
    assign dataE.pcplus4 = dataD.pcplus4;
    // ports
    // decode_ereg_exec.exec in
    assign dataD = in.dataD;

    // exec_mreg_memory.exec out
    assign out.dataE_new = dataE;
    
    // hazard_intf.exec hazard
    assign hazard.dataE = dataE;
endmodule