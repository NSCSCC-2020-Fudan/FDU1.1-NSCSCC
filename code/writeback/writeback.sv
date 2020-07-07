`include "mips.svh"

module writeback (
    input mem_data_t mem_data,
    output word_t result,
    output creg_addr_t writereg
);
    assign result = mem_data.memread ? mem_data.rd : mem_data.aluout;
    assign writereg = mem_data.writereg;
endmodule