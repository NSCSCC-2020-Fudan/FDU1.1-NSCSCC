`include "mips.svh"

module instrfetch(
        input logic clk, reset, stall, flush,
        input word_t pc_pcf, pcplus4_pcf, pcplus8_pcf,
        //from pcfetch
        input logic inst_ibus_data_ok,
        input logic [63: 0] inst_ibus_data,
        input logic inst_ibus_index,
        //to ibus 
        output fetch_data_t [1: 0] fetch_data,
        output logic [1: 0] hitF,
        //to decode
        output word_t [1: 0] pc_predictF,
        input bpb_result_t [1: 0] destpc_predictF,
        //to bpb
        output logic finish_instr,
        output word_t pc_isf, pcplus4_isf, pcplus8_isf
    );
    
    logic finish_his_, finish_his;
    logic [1: 0] ien_his_, ien_his, ien;
    logic [63: 0] data_his_, data_his, data;
    word_t pc, pcplus4, pcplus8, pc_, pcplus4_, pcplus8_;
    
    
    always_comb 
        begin
            pc_ = pc;
            pcplus4_ = pcplus4;
            pcplus8_ = pcplus8;
            finish_his_ = finish_his;
            data_his_ = data_his;
            ien_his_ = ien_his;
            if (inst_ibus_data_ok)
                begin
                    finish_his_ = 1'b1;
                    data_his_ = inst_ibus_data;
                    ien_his_ = {1'b1, ~inst_ibus_index};
                end else begin
                    data_his_ = data_his;
                end
            if (~stall)
                begin
                    pc_ = pc_pcf;
                    pcplus4_ = pcplus4_pcf;
                    pcplus8_ = pcplus8_pcf;
                    finish_his_ = 1'b0;
                end
        end
    logic [63:0] fuck;
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    finish_his <= 1'b0;
                    data_his <= '0;
                    ien_his <= 2'b11;
                end
            else
                begin
                    finish_his <= finish_his_;
                    data_his <= data_his_;
                    ien_his <= ien_his_;
                    pc <= pc_;
                    pcplus4 <= pcplus4_;
                    pcplus8 <= pcplus8_;
                end
        end
                    
    assign finish_instr = finish_his | inst_ibus_data_ok;
    assign pc_isf = pc;        
    assign pcplus4_isf = pcplus4;
    assign pcplus8_isf = pcplus8;
    
    
    logic exception_instr;
    assign exception_instr = (pcplus4[1:0] != '0);
    
    word_t [1: 0] instr;
    assign fetch_data[1].instr_ = instr[0];
    assign fetch_data[0].instr_ = instr[1];
    assign fetch_data[1].pcplus4 = pcplus4;
    assign fetch_data[0].pcplus4 = pcplus8;
    assign fetch_data[1].en = ien[1];
    assign fetch_data[0].en = ien[0];
    assign fetch_data[1].exception_instr = exception_instr;
    assign fetch_data[0].exception_instr = exception_instr;
    //assign fetch_data[1].pred = destpc_predictF[1];
    //assign fetch_data[0].pred = (ien[0]) ? destpc_predictF[0] : ('0);
    assign fetch_data[1].pred = '0;
    assign fetch_data[0].pred = '0;
    
    assign pc_predictF = {pc, pcplus4};
    //to bpb
        
    assign data = (~inst_ibus_data_ok) ? (data_his)                  : (inst_ibus_data);
    assign ien = (~inst_ibus_data_ok)  ? (ien_his)                   : {1'b1, ~inst_ibus_index};           
    assign instr = (ien[0])            ? {data[63: 32], data[31: 0]} : {'0, data[63: 32]};
    assign hitF = ien;
    
endmodule
