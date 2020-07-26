module fetch 
    import common::*;
    import fetch_pkg::*;(
    input word_t instr_,
    output word_t pc,
    freg_intf.fetch freg,
    dreg_intf.fetch dreg,
    pcselect_intf.fetch pcselect
);
    fetch_data_t [MACHINE_WIDTH-1:0]dataF;
    word_t pc;
    word_t pcplus4, pcplus8;
    assign pcplus4 = pc + 32'b100;
    assign pcplus8 = pc + 32'b1000;

    assign dataF[0].instr_ = instr_;
    assign dataF[0].pcplus8 = pcplus8;
    assign pc = freg.pc;
    assign pcselect.pcplus4 = pcplus4;
endmodule