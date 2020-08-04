`include "mips.svh"

module datapath(
        input logic clk, reset,
        input logic [5: 0] ext_int,
        output word_t iaddr,  
        input logic ihit, idataOK,
        input word_t [1: 0] idata, 
        //imem
        output logic dwt,
        output word_t daddr, dwd,
        input word_t drd,
        output logic den, dreq,
        output logic [1: 0] dsize,     
        input logic ddataOK, daddrOK,
        //dmem
        output rf_w_t [1: 0] rfw_out,
        output word_t [1: 0] rt_pc_out,
        output logic stallF_out, flush_ex,
        //output word_t pc
        output logic inst_ibus_req, 
        input logic inst_ibus_addr_ok,
        input logic inst_ibus_data_ok,
        input logic [63: 0] inst_ibus_data,
        input logic inst_ibus_index
    );
    
    
    fetch_data_t [1: 0] fetch_data, decode_data_in;
    decode_data_t [1: 0] decode_data_out;
    issue_data_t [1: 0] issue_data_out;
    exec_data_t [1: 0] exec_data_out, commit_data_in, commit_data_out, retire_data_in; 
    
    bypass_upd_t exec_bypass, commit_bypass, retire_bypass;
    
    logic finishF, finishE, finishC;
    logic stallD, flushD, stallI, flushI, flushE, stallF;
    logic stallE, stallC, flushC, stallR, flushR;
    logic data_hazardI, queue_ofI, pc_mC, pc_new_commit;
    assign flushE_out = flushE; 
    assign stallF_out = stallF;
    
    logic [3: 0] dhazard_maskI;
    creg_addr_t [3: 0] reg_addrI, reg_addrW;
    word_t [3: 0] reg_dataI, reg_dataW;
    logic [1: 0] hiloreadI, hiloreadW;
    word_t [1: 0] hilodataI;
    word_t hiW, loW;
    creg_addr_t [1: 0] cp0_addrI, cp0_addrW;
    word_t [1: 0] cp0_dataI, cp0_dataW;
    rf_w_t [1: 0] rfw, cp0w;
    word_t [1: 0] rt_pc;
    hilo_w_t hlw;
    
    cp0_regs_t cp0_data;
    cp0_cause_t cp0_causeW, cp0_causeI, cp0_cause;
    cp0_status_t cp0_statusW, cp0_statusI, cp0_status;
    
    logic hitF;
    pc_data_t pc_new;
    (*mark_debug = "true"*) word_t pc;
    
    logic timer_interrupt, exception_valid, is_eret; 
    word_t pcexception, cp0_epcI, cp0_epcW;
    exception_t exceptionE;
    exception_pipeline_t exception_pipeline;
    
    logic mul_timeok, div_timeok;
    logic [1: 0] hitF_out, hitD_in, hitD_out;
    
    logic predict_wenC;
    word_t pc_commitC;
    bpb_result_t destpc_commitC;
    word_t [1: 0] pc_predictF;
    bpb_result_t [1: 0] destpc_predictF;
    
    /*
    fetch fetch (clk, reset, 1'b0, stallF,
                 pc_new, pc, pc_new_commit,
                 iaddr, ihit, idata, idataOK,
                 fetch_data, hitF_out, finishF,
                 pc_predictF, destpc_predictF,
                 inst_ibus_data_ok, inst_ibus_data,
                 inst_ibus_index);
    */
    quickfetch quickfetch(.clk, .reset, .flushF(1'b0), .stallF,
                          .fetch(pc_new), .pc, .pc_new_commit,
                          .addr(iaddr), .hit(ihit), .data(idata), .dataOK(idataOK),
                          .fetch_data, .hitF(hitF_out), .finishF,
                          .pc_predictF, .destpc_predictF,
                          .inst_ibus_req, .inst_ibus_addr_ok,
                          .inst_ibus_data_ok, .inst_ibus_data,
                          .inst_ibus_index);                     
    
    dreg dreg (clk, reset, stallD, flushD,
               fetch_data, decode_data_in,
               hitF_out, hitD_in);
    decode decode (.in(decode_data_in), .hitF(hitD_in),
                   .out(decode_data_out), .hitD(hitD_out));
    
    logic first_cycpeE;
    issue issue (clk, reset,
                 decode_data_out,
                 hitD_out,
                 issue_data_out,
                 queue_ofI, data_hazardI,
                 stallI, flushI,
                 stallE, flushE,
                 dhazard_maskI,
                 reg_addrI, reg_dataI, 
                 hiloreadI, hilodataI,
                 cp0_addrI, cp0_dataI,
                 cp0_statusI, cp0_causeI, cp0_epcI,
                 mul_timeok, div_timeok,
                 first_cycpeE);  
    
    execute execute (clk, reset, first_cycpeE,
                     issue_data_out,
                     exec_data_out,
                     finishE, flushE, stallE,
                     exec_bypass,
                     mul_timeok, div_timeok);
    
    logic first_cycleC;
    bypass_upd_t commitex_bypass, commitdt_bypass;
    creg creg (clk, reset, stallC, flushC,
               exec_data_out, commit_data_in, first_cycleC);
	quickcommit quickcommit (.clk, .reset, .flushC, 
                   			 .in(commit_data_in),
                   			 .out(commit_data_out), 
                   			 .finishC, .pc_mC,
                   			 .dmem_wt(dwt),
        					 .dmem_addr(daddr), .dmem_wd(dwd), 
        					 .dmem_rd(drd),
        					 .dmem_en(den),
        					 .dmem_size(dsize),     
        					 .dmem_data_ok(ddataOK),
        					 .dmem_req(dreq), .dmem_addr_ok(daddrOK),
                   			 .fetch(pc_new),
                   			 .bypass0(commitex_bypass), .bypass1(commitdt_bypass),
                   			 .ext_int, 
                   			 .timer_interrupt,
                   			 .exception_valid, 
                   			 .exception_data(exceptionE),
                   			 .is_eret,
                   			 .pc_commitC, .predict_wen(predict_wenC), .destpc_commitC);              
    /*
    commit commit (clk, reset,
                   commit_data_in,
                   commit_data_out,
                   first_cycleC, 
                   finishC, pc_mC,
                   dwt,
                   daddr, dwd, drd,
                   den,     
                   dsize, ddataOK, 
                   pc_new,
                   commit_bypass,
                   ext_int, 
                   timer_interrupt,
                   exception_valid, 
                   exceptionE,
                   is_eret,
                   pc_commitC, predict_wenC, destpc_commitC);
	*/                   
    
    rreg rreg (clk, reset, stallR, flushR,
               commit_data_out,
               retire_data_in);
    retire retire (retire_data_in,
                   rfw, rt_pc, 
                   hlw, cp0w,
                   retire_bypass);
    
    bypass bypass (reg_addrI, reg_dataI, 
                   hiloreadI, hilodataI,
                   cp0_addrI, cp0_dataI,
                   dhazard_maskI, data_hazardI,
                   exec_bypass,
                   /*commit_bypass*/commitex_bypass, commitdt_bypass,
                   retire_bypass,
                   reg_addrW, reg_dataW,
                   hiloreadW, hiW, loW,
                   cp0_addrW, cp0_dataW);
    
    control control (clk, reset,
                     finishF, finishE, finishC, data_hazardI, queue_ofI, pc_mC,
                     is_eret, exception_valid,
                     stallF, stallD, flushD, stallI, flushI, 
                     stallE, flushE, stallC, flushC, stallR, flushR, pc_new_commit, flush_ex);
    
    hilo hilo (clk, reset,
               hiW, loW, hlw);               
    
    regfile regfile (clk, reset,
                     rfw,
                     reg_addrW, reg_dataW);               
    
    cp0 cp0(clk, reset,
            cp0w,
            cp0_addrW, cp0_dataW,
            is_eret, 
            timer_interrupt,
            exceptionE,
            cp0_causeW, cp0_statusW, cp0_epcW);        
            
    cp0status_bypass cp0status_bypass(exec_bypass, commitex_bypass, commitdt_bypass/*commit_bypass*/, retire_bypass, 
                                      cp0_statusW, cp0_causeW, cp0_epcW,
                                      cp0_statusI, cp0_causeI, cp0_epcI);
                                      
    branchpredict branchpredict(.clk, .reset, .stall(1'b0),
                                .pc_predict(pc_predictF),
                                .destpc_predict(destpc_predictF), 
                                .pc_commit(pc_commitC),
                                .wen(predict_wenC),
                                .destpc_commit(destpc_commitC));                                                                   
    
    assign rfw_out = rfw;
    assign rt_pc_out = rt_pc;                                                                                                                                    
endmodule