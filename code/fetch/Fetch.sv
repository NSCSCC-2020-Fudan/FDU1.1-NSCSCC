`include "mips.svh"

module fetch (
    // input word_t pc,
    // output fetch_data_t fetch_data
    pcs_freg_fetch.fetch in,
    fetch_dreg_decode.fetch out
);
    // assign out.pcplus4 = pc + 32'b4;
    adder#(32) pcadder(in.pc, 32'b100, out.dataF_new.pcplus4);
    assign out.dataF_new.exception_instr = (out.dataF_new.pcplus4[1:0] != '0);
endmodule
