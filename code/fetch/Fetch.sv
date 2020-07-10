`include "mips.svh"

module fetch (
    pcselect_freg_fetch.fetch in,
    fetch_dreg_decode.fetch out,
    pcselect_intf.fetch pcselect
);
    word_t pcplus4;
    fetch_data_t dataF;
    logic exception_instr;
    adder#(32) pcadder(in.pc, 32'b100, pcplus4);
    assign exception_instr = (pcplus4[1:0] != '0);
    

// typedef struct packed {
//     word_t instr_;
//     word_t pcplus4;
//     logic exception_instr;
// } fetch_data_t;    
    // assign dataF = {out.instr_, pcplus4, exception_instr};
    assign dataF.instr_ = out.instr_;
    assign dataF.pcplus4 = pcplus4;
    assign dataF.exception_instr = exception_instr;
    assign out.dataF_new = dataF;
    assign pcselect.pcplus4F = pcplus4;
endmodule
