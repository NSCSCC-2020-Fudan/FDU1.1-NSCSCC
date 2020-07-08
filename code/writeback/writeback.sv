`include "mips.svh"

module writeback (
    memory_wreg_writeback.writeback in,
    regfile_intf.writeback regfile,
	hilo_intf.writeback hilo,
	cp0_intf.writeback cp0,
	hazard_intf.writeback hazard
    output word_t pc
);
input mem_data_t mem_data,
    output word_t result,
    output creg_addr_t writereg,
    decoded_op_t op;
    m_addr_t addr;
    logic regwrite;
    assign result = mem_data.memread ? mem_data.rd : mem_data.aluout;
    assign writereg = mem_data.writereg;
endmodule