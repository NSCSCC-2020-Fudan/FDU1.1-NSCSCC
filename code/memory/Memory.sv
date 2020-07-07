module memory (
    input exec_data_t exec_data,
    input word_t rd,
    output m_r_t mread,
    output m_w_t mwrite,
    output mem_data_t mem_data
);
    assign mread.en = exec_data.memread;
    assign mread.addr = exec_data.aluout;
    assign mwrite.en = exec_data.memwrite;
    assign mwrite.addr = exec_data.aluout;
    
    writedata writedata(.rd(rd), ._wd(exec_data.wd), .op(exec_data.decoded_instr.op),.wd(mwrite.wd));
    
endmodule