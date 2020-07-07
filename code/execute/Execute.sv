`include "mips.svh"
module execute (
    input decoded_instr_t decoded_instr,
    output word_t aluout,
    output creg_addr_t writereg
);
    
    wrmux wrmux0(.rt(decoded_instr.rt), .rd(decoded_instr.rd), .jump(decoded_instr.jump), .regdst(decoded_instr.regdst), .writereg(writereg));
    srcamux srcamux();
    wdmux wdmux();
    srcbmux srcbmux();
endmodule