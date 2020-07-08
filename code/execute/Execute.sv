`include "mips.svh"
module execute (
    decode_ereg_exec.exec in,
    exec_mreg_memory.exec out,
    hazard_intf.exec hazard
);
    word_t srca, srcb, srcb0;
    wrmux wrmux0(.rt(in.dataD.decoded_instr.rt), .rd(in.dataD.decoded_instr.rd), .op(in.dataD.decoded_instr.op), .writereg(out.writereg));
    srcaemux srcaemux(.e(in.dataD.srca),.m(hazard.aluoutM),.w(hazard.resultW),.sel(hazard.forwardAE),.srca);
    wdmux wdmux(.e(in.dataD.srcb),.m(hazard.aluoutM),.w(hazard.resultW),.sel(hazard.forwardBE).srcb0);
    srcbemux srcbemux(.srcb0,.imm(in.dataD.decoded_instr.extended_imm),.shamt(in.dataD.decoded_instr.shamt).srcb);
    alu alu(srca, srcb, in.dataD.decoded_instr.ctl.alufunc, out.dataE.aluout, out.dataE.exception_of);
    mult multdiv(.a(srca), .b(srcb), .op(dataD.decoded_instr.op), .hi(dataE.hi), .lo(dataE.lo));

    assign out.dataE.decoded_instr = in.dataD.decoded_instr;
    assign out.dataE.exception_instr = in.dataD.exception_instr;
    assign out.dataE.exception_ri = in.dataD.exception_ri;
endmodule