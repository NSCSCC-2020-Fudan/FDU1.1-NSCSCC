`include "mips.svh"
`include "tu.svh"
`include "instr_bus.svh"

module quickfetch (
    input logic clk, reset, flushF, stallF,
    //updata
    input pc_data_t fetch,
    output word_t pc,
    input logic pc_new_commit, 
    //to branch_control
    output fetch_data_t [1: 0] fetch_data,
    output logic [1: 0] hitF,
    output logic finishF,
    //to decode
    output word_t [1: 0] pc_predictF,
    input bpb_result_t [1: 0] destpc_predictF,
    //to bpb
    /*
    output logic inst_ibus_req,
    input logic inst_ibus_addr_ok,
    input logic inst_ibus_data_ok,
    input logic [63: 0] inst_ibus_data,
    input logic inst_ibus_index,
    */
    output ibus_req_t  imem_req,
    input ibus_resp_t imem_resp,
    output dbus_req_t  dmem_req,
    input dbus_resp_t dmem_resp,
    //to ibus
    output logic [1: 0] jrp_pushF, jrp_popF,
    output word_t [1: 0] pc_jrpredictF,
    input logic [`JR_ENTRY_WIDTH - 1: 0] jrp_topF, 
    input word_t jrp_destpcF,
    //jr predict
    input tu_op_resp_t tu_op_resp
    //tlb 
);
    
    logic pc_upd, pc_upd_h, stop, stop_h;
    word_t pc_cmt, pc_cmt_h, pc_stop;
    pc_cmtselect pc_cmtselect(clk, reset, 
                              fetch.exception_valid, fetch.is_eret,
                              fetch.branch, fetch.jump, fetch.jr,
                              fetch.tlb_ex,
                              fetch.pcexception, fetch.epc, 
                              fetch.pcbranch, fetch.pcjump, fetch.pcjr,
                              fetch.pctlb,
                              pc_cmt, pc_upd);
    logic [1: 0] ien;     
    assign ien = hitF; 
    logic [1: 0] mask;     
    word_t pcplus4_pcf, pcplus8_pcf, pc_pcf;
    word_t pcplus4_isf, pcplus8_isf, pc_isf, pc_seq;
    bpb_result_t destpc_predict_sel, last_predict, next_predict;
    assign pc_seq = (destpc_predict_sel.taken) ? (destpc_predict_sel.destpc) : (
                    (pcplus8_pcf[2])           ? (pcplus4_pcf)               : (pcplus8_pcf));
    
    word_t pc_new;
    assign stop = stallF;
    //assign pc_stop = (destpc_predict_sel_h.taken) ? (destpc_predict_sel_h.destpc) : (pc_isf);
    assign pc_new = (pc_upd)                      ? (pc_cmt)    : (
                    (pc_upd_h)                    ? (pc_cmt_h)  : (
                    (stop | stop_h)               ? (pc_stop)   : (pc_seq)));                 

    logic tlb_invalid_pcf, tlb_refill_pcf;                           
    logic finish_pc, no_addr_ok;
    logic [1: 0] ien_predict_pcf;  
    bpb_result_t [1: 0] destpc_predict_pcf;                          
    pcfetch pcfetch(.clk, .reset, .stall, .flush(1'b0),
                    .pc_new, 
                    .addr(imem_req.addr),
                    .pc(pc_pcf), .pcplus4(pcplus4_pcf), .pcplus8(pcplus8_pcf),
                    .inst_ibus_addr_ok(imem_resp.addr_ok),
                    .inst_ibus_req(imem_req.req), 
                    .finish_pc,
                    .pc_predictF,
                    .destpc_predictF_in(destpc_predictF), 
                    .destpc_predictF_out(destpc_predict_pcf),
                    .tu_op_resp, 
                    .tlb_invalid(tlb_invalid_pcf), .tlb_refill(tlb_refill_pcf));
    assign pc = pc_pcf;                    
    
    logic finish_instr;
    logic inst_tlb_ex_isf;
    bpb_result_t destpc_predict_sel_isf;
    instrfetch instrfetch(.clk, .reset, .stall, .flush(1'b0),
                          .pc_pcf, .pcplus4_pcf, .pcplus8_pcf,
                          .inst_ibus_data_ok(imem_resp.data_ok),
                          .inst_ibus_data(imem_resp.data),
                          .inst_ibus_index(imem_resp.index),
                          .fetch_data,
                          .hitF,                           
                          .finish_instr,
                          .pc_isf, .pcplus4_isf, .pcplus8_isf,
                          .destpc_predictF_in(destpc_predict_pcf),
                          .destpc_predict_sel(destpc_predict_sel_isf),
                          .last_predict_in(last_predict), .next_predict,
                          .jrp_pushF, .jrp_popF,
                          .jrp_topF, .jrp_destpcF,
                          .tlb_invalid_pcf, .tlb_refill_pcf);
    assign pc_jrpredictF = {pc_isf, pcplus4_isf};                                                                   
    
    logic enF, debug;
    
    logic no_addr_ok_, pc_upd_h_, stop_h_;
    logic [1: 0] mask_;
    word_t pc_cmt_h_, pc_stop_;
    bpb_result_t last_predict_h, last_predict_h_, destpc_predict_sel_h, destpc_predict_sel_h_;
    always_comb
        begin
            no_addr_ok_ = no_addr_ok;
            pc_upd_h_ = pc_upd_h;
            mask_ = mask;
            pc_cmt_h_ = pc_cmt_h;
            stop_h_ = stop_h;
            last_predict_h_ = last_predict_h;
            destpc_predict_sel_h_ = destpc_predict_sel_h;
            pc_stop_ = pc_stop;
            if (imem_resp.addr_ok)
                no_addr_ok_ = 1'b0;
            if (pc_upd)
                begin
                    mask_ = 2'b11;
                    pc_upd_h_ = 1'b1;
                    pc_cmt_h_ = pc_cmt;
                    last_predict_h_ = '0;
                    destpc_predict_sel_h_ = '0;
                end
            if (stallF && ~(pc_upd || pc_upd_h))
                begin
                    mask_ = 2'b11;
                    stop_h_ = 1'b1;
                end     
            if (destpc_predict_sel_isf.taken && finishF)
                begin
                    mask_ = mask_ | 2'b10;
                    last_predict_h_ = '0;
                    destpc_predict_sel_h_ = '0;
                end                           
            if (~stall)
                begin
                    mask_ = {1'b0, mask_[1]};
                    pc_upd_h_ = 1'b0;
                    //pc_cmt_h_ ='0;
                    stop_h_ = 1'b0;
                    //pc_stop_h = '0;
                    pc_stop_ = (~finishF)                     ? (pc_stop_)                      : (
                               (destpc_predict_sel_isf.taken) ? (destpc_predict_sel_isf.destpc) : (pc_pcf));
                    last_predict_h_ = (~finishF)                      ? (last_predict_h_)               : (
                                      (~destpc_predict_sel_isf.taken) ? (next_predict)                  : ('0));
                    destpc_predict_sel_h_ = (finishF)         ? (destpc_predict_sel_isf)        : (destpc_predict_sel_h_);
                end                  
        end
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    mask <= 2'b00;
                    no_addr_ok <= 1'b1;
                    pc_upd_h <= 1'b0;
                    pc_cmt_h <= '0;
                    stop_h <= 1'b0;
                    last_predict_h <= '0;
                    destpc_predict_sel_h <= '0;
                    pc_stop <= '0;
                end                    
            else
                begin
                    mask <= mask_;
                    no_addr_ok <= no_addr_ok_;
                    pc_upd_h <= pc_upd_h_;
                    pc_cmt_h <= pc_cmt_h_;
                    stop_h <= stop_h_;
                    last_predict_h <= last_predict_h_;
                    destpc_predict_sel_h <= destpc_predict_sel_h_;
                    pc_stop <= pc_stop_;
                end
        end
    /*    
    assign last_predict = (reset | pc_upd | pc_upd_h) ? ('0)             : (
                          (stop | stop_h)             ? (last_predict_h) : (
                          (destpc_predict_sel.taken)  ? ('0)             : (
                          (mask[0])                   ? (last_predict_h) : (next_predict))));
    */
    assign last_predict = (~finishF)                      ? (last_predict_h)               : (
                          (~destpc_predict_sel_isf.taken) ? (next_predict)                 : ('0));   
    assign destpc_predict_sel = (finishF) ? (destpc_predict_sel_isf) : ('0);                           
    
    
    assign enF = ~(mask[0] || stop || stop_h || pc_upd || pc_upd_h);
    assign debug = (no_addr_ok) ? (1'b1) : (finish_instr);
    assign stall = (~finish_pc) || (~debug);                            
    assign finishF = finish_instr && finish_pc && enF;   
             
endmodule
