`include "mips.svh"

module fetch (
    pcs_freg_fetch.fetch in,
    fetch_dreg_decode.fetch out,
    pcselect_intf.fetch pcselect
);
    word_t pc, pcplus4, instr;
    logic exception_instr;
    adder#(32) pcadder(pc, 32'b100, pcplus4);
    assign exception_instr = (pcplus4[1:0] != '0);

    //
endmodule
