module memory (
    input exec_data_t dataE,
    input word_t rd,
    output m_r_t mread,
    output m_w_t mwrite,
    output mem_data_t dataM
);
    assign mread.en = dataE.memread;
    assign mread.addr = dataE.aluout;
    assign mwrite.en = dataE.memwrite;
    assign mwrite.addr = dataE.aluout;
    decoded_op_t op;
    assign op = dataE.decoded_instr.op;
    logic exception_data;
    assign exception_data = ((op == SW || op == LW) && (dataE.aluout[1:0] != '0)) ||
                            ((op == SH || op == LH || op == LHU) && (dataE.aluout[0] != '0));
    writedata writedata(.rd(rd), ._wd(dataE.wd), .op(dataE.decoded_instr.op),.wd(mwrite.wd));
    readdata readdata(._rd(rd), .op(op), .rd(dataM.readdata)); 
endmodule