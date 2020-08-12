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
        output logic finish_instr,
        output word_t pc_isf, pcplus4_isf, pcplus8_isf,
        //to fetchcontrol
        input bpb_result_t [1: 0] destpc_predictF_in,
        output bpb_result_t destpc_predict_sel,
        input bpb_result_t last_predict_in,
        output bpb_result_t next_predict,
        //to bpb
        output logic [1: 0] jrp_pushF, jrp_popF,
        input logic [`JR_ENTRY_WIDTH - 1: 0] jrp_topF, 
        input word_t jrp_destpcF,
        //to jr predict
        input logic tlb_ex_pcf 
    );
    
    logic tlb_ex_, tlb_ex;
    logic finish_his_, finish_his;
    logic [1: 0] ien_his_, ien_his, ien;
    logic [63: 0] data_his_, data_his, data;
    word_t pc, pcplus4, pcplus8, pc_, pcplus4_, pcplus8_;
    
    bpb_result_t last_predict;
    bpb_result_t [1: 0] destpc_predict_, destpc_predict, destpc_predict_np;    
    
    always_comb 
        begin
            pc_ = pc;
            tlb_ex_ = tlb_ex;
            pcplus4_ = pcplus4;
            pcplus8_ = pcplus8;
            finish_his_ = finish_his;
            data_his_ = data_his;
            ien_his_ = ien_his;
            destpc_predict_ = destpc_predict;
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
                    tlb_ex_ = tlb_ex;
                    pc_ = pc_pcf;
                    pcplus4_ = pcplus4_pcf;
                    pcplus8_ = pcplus8_pcf;
                    destpc_predict_ = destpc_predictF_in;
                    finish_his_ = 1'b0;
                end
        end
    
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    tlb_ex <= 1'b0;
                    finish_his <= 1'b0;
                    data_his <= '0;
                    ien_his <= 2'b11;
                    destpc_predict_np <= '0;
                    last_predict <= '0;
                end
            else
                begin
                    last_predict <= last_predict_in;
                    finish_his <= finish_his_;
                    data_his <= data_his_;
                    ien_his <= ien_his_;
                    pc <= pc_;
                    pcplus4 <= pcplus4_;
                    pcplus8 <= pcplus8_;
                    destpc_predict_np <= destpc_predict_;
                    tlb_ex <= tlb_ex_;
                end
        end
                    
    assign finish_instr = finish_his | inst_ibus_data_ok;
    assign pc_isf = pc;        
    assign pcplus4_isf = pcplus4;
    assign pcplus8_isf = pcplus8;
    
    logic exception_instr;
    assign exception_instr = (pcplus4[1:0] != '0);
    
    word_t [1: 0] instr;
    logic [`JR_ENTRY_WIDTH - 1: 0] jrp_topF_ [1: 0];
    logic [1: 0] jrp_pushF_, jrp_popF_;
    assign jrp_pushF = {jrp_pushF_[1] & hitF[1], jrp_pushF_[0] & hitF[0]};
    assign jrp_popF = {jrp_popF_[1] & hitF[1], jrp_popF_[0] & hitF[0]};
    bpbdecode bpbdecpde1(pc, pcplus4, instr[0], 
                         destpc_predict_np[1], destpc_predict[1],
                         jrp_pushF_[1], jrp_popF_[1], jrp_destpcF,
                         jrp_topF, jrp_topF_[1]);
    bpbdecode bpbdecpde0(pcplus4, pcplus8, instr[1], 
                         destpc_predict_np[0], destpc_predict[0],
                         jrp_pushF_[0], jrp_popF_[0], jrp_destpcF,
                         jrp_topF, jrp_topF_[0]);
    
    assign fetch_data[1].instr_ = instr[0];
    assign fetch_data[0].instr_ = instr[1];
    assign fetch_data[1].pcplus4 = pcplus4;
    assign fetch_data[0].pcplus4 = pcplus8;
    assign fetch_data[1].en = hitF[1];
    assign fetch_data[0].en = hitF[0];
    assign fetch_data[1].exception_instr = exception_instr;
    assign fetch_data[0].exception_instr = exception_instr;
    assign fetch_data[1].pred = destpc_predict[1];
    assign fetch_data[0].pred = (hitF[0]) ? destpc_predict[0] : ('0);
    assign fetch_data[1].jrtop = jrp_topF_[1];
    assign fetch_data[0].jrtop = jrp_topF_[0];
    assign fetch_data[1].exception_instr_tlb = tlb_ex;
    assign fetch_data[0].exception_instr_tlb = tlb_ex;// ??
    //assign fetch_data[1].pred = '0;
    //assign fetch_data[0].pred = '0;
    
    assign destpc_predict_sel = (last_predict.taken)               ? (last_predict)      : (
                                (destpc_predict[1].taken & ien[0]) ? (destpc_predict[1]) : ('0));
    assign next_predict = (ien[1] & ~ien[0])                       ? (destpc_predict[1]) : (
                          (ien[0])                                 ? (destpc_predict[0]) : ('0));
    //to bpb
        
    assign data = (~inst_ibus_data_ok) ? (data_his)                  : (inst_ibus_data);
    assign ien = (~inst_ibus_data_ok)  ? (ien_his)                   : {1'b1, ~inst_ibus_index};           
    assign instr = (ien[0])            ? {data[63: 32], data[31: 0]} : {'0, data[63: 32]};
    assign hitF = {ien[1], ien[0] & ~last_predict.taken};
    
    
endmodule
