`include "mips.svh"

module fetch_ (
    pcselect_freg_fetch.fetch in,
    fetch_dreg_decode.fetch out,
    pcselect_intf.fetch pcselect
);
    adder#(32) pcadder(in.pc, 32'b100, out.dataF_new.pcplus4);
    assign out.dataF_new.exception_instr = (out.dataF_new.pcplus4[1:0] != '0);
    assign out.dataF_new.instr = out.instr;
    assign pcselect.pcplus4F = out.dataF_new.pcplus4;
endmodule
