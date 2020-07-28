`include "interface.svh"
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
    word_t pcplus4, pcplus8;
    assign pcplus4 = pc + 32'b100;
    assign pcplus8 = pc + 32'b1000;

    for (genvar i = 0; i < MACHINE_WIDTH ; i++) begin
        assign dataF[i].instr_ = instr_;
        assign dataF[i].pcplus8 = pcplus8;
        assign dataF[i].valid = 1'b1;
    end
    
    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            dataF[i].exception = '0;
            dataF[i].exception.instr = dataF[0].pcplus8[1:0] != 2'b00;
        end   
    end
    assign pc = freg.pc;
    assign dreg.dataF_new = dataF;
    assign pcselect.pcplus4 = pcplus4;
endmodule