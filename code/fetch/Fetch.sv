`include "mips.svh"

module fetch (
    input word_t pc,
    output fetch_data_t fetch_data
);
    // assign out.pcplus4 = pc + 32'b4;
    adder#(32) pcadder(pc, 32'b100, fetch_data.pcplus4);
    assign fetch_data.exception_instr = (fetch_data.pcplus4[1:0] != '0);
endmodule
