`include "mips.svh"

module quickfetch (
    input logic clk, reset, flushF, stallF,
    //updata
    input pc_data_t fetch,
    output word_t pc,
    input logic pc_new_commit, 
    //to branch_control
    output word_t addr,
    input logic hit, 
    input word_t [1: 0] data,
    input logic dataOK,
    //to imem
    output fetch_data_t [1: 0] fetch_data,
    output logic [1: 0] hitF,
    output logic finishF,
    //to decode
    output word_t [1: 0] pc_predictF,
    input bpb_result_t [1: 0] destpc_predictF,
    //to bpb
    output logic inst_ibus_req,
    input logic inst_ibus_addr_ok,
    input logic inst_ibus_data_ok,
    input logic [63: 0] inst_ibus_data,
    input logic inst_ibus_index
    //to ibus
);
    
    logic pc_upd, pc_upd_h, stop, stop_h;
    word_t pc_cmt, pc_cmt_h, pc_stop, pc_stop_h;
    pc_cmtselect pc_cmtselect(fetch.exception_valid, fetch.is_eret,
                              fetch.branch, fetch.jump, fetch.jr,
                              fetch.pcexception, fetch.epc, 
                              fetch.pcbranch, fetch.pcjump, fetch.pcjr,
                              pc_cmt, pc_upd);
    logic [1: 0] ien;     
    assign ien = hitF; 
    logic [1: 0] mask;     
    word_t pcplus4_pcf, pcplus8_pcf, pc_pcf;
    word_t pcplus4_isf, pcplus8_isf, pc_isf, pc_seq;
    assign pc_seq = (pcplus8_pcf[2]) ? (pcplus4_pcf) : (pcplus8_pcf);
    
    word_t pc_new;
    assign stop = stallF;
    assign pc_stop = pc_isf;
    assign pc_new = (pc_upd)                     ? (pc_cmt)    : (
                    (pc_upd_h)                   ? (pc_cmt_h)  : (
                    ((stop | stop_h) & ~mask[0]) ? (pc_isf)    : (
                    (stop | stop_h)              ? (pc_stop_h) : (pc_seq))));
                           
    logic finish_pc, no_addr_ok;                           
    pcfetch pcfetch(clk, reset, stall, 1'b0,
                    pc_new, addr,
                    pc_pcf, pcplus4_pcf, pcplus8_pcf,
                    inst_ibus_addr_ok,
                    inst_ibus_req, finish_pc);
    assign pc = pc_pcf;                    
    
    logic finish_instr;
    instrfetch instrfetch(.clk, .reset, .stall, .flush(1'b0),
                          .pc_pcf, .pcplus4_pcf, .pcplus8_pcf,
                          .inst_ibus_data_ok,
                          .inst_ibus_data,
                          .inst_ibus_index,
                          .fetch_data,
                          .hitF, 
                          .pc_predictF, .destpc_predictF,
                          .finish_instr,
                          .pc_isf, .pcplus4_isf, .pcplus8_isf);
    
    logic no_addr_ok_, pc_upd_h_, stop_h_;
    logic [1: 0] mask_;
    word_t pc_cmt_h_, pc_stop_h_;
    always_comb
        begin
            no_addr_ok_ = no_addr_ok;
            pc_upd_h_ = pc_upd_h;
            mask_ = mask;
            pc_cmt_h_ = pc_cmt_h;
            stop_h_ = stop_h;
            pc_stop_h_ = pc_stop_h;
            if (inst_ibus_addr_ok)
                no_addr_ok_ <= 1'b0;
            if (pc_upd)
                begin
                    mask_ = 2'b11;
                    pc_upd_h_ = 1'b1;
                    pc_cmt_h_ = pc_cmt;
                end
            if (stallF && ~(pc_upd || pc_upd_h))
                begin
                    mask_ = 2'b11;
                    stop_h_ = 1'b1;
                end                                                       
            if (~stall)
                begin
                    mask_ = {1'b0, mask_[1]};
                    pc_upd_h_ = 1'b0;
                    pc_cmt_h_ ='0;
                    stop_h_ = 1'b0;
                end
            pc_stop_h_ = (~mask[0]) ? (pc_isf) : (pc_stop_h_);                   
        end
        
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    mask <= 2'b00;
                    no_addr_ok <= 1'b1;
                    pc_upd_h <= 1'b0;
                    pc_cmt_h <= '0;
                    stop_h <= 1'b0;
                    pc_stop_h <= '0;
                end                    
            else
                begin
                    mask <= mask_;
                    no_addr_ok <= no_addr_ok_;
                    pc_upd_h <= pc_upd_h_;
                    pc_cmt_h <= pc_cmt_h_;
                    stop_h <= stop_h_;
                    pc_stop_h <= pc_stop_h_;
                end
        end
    
    logic stall_pc, stall_instr;
    logic flush_pc, flush_instr;
    
    logic enF, debug;
    assign enF = ~mask[0];
    assign debug = (no_addr_ok) ? (1'b1) : (finish_instr);
    assign stall = (~finish_pc) || (~debug);                            
    assign finishF = finish_instr && finish_pc && enF;   
             
endmodule
