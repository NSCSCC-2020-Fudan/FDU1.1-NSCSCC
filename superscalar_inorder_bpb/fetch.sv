`include "mips.svh"

module fetch (
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
    input bpb_result_t [1: 0] destpc_predictF
    //to bpb
);
    
    logic [1: 0] state; 
    logic [1: 0] ien;
    word_t [1: 0] instr;
    word_t pcplus4, pcplus8, pcplus, pc_new;
    
    logic pc_upd;
    pcselect pcselect(fetch.exception_valid, fetch.is_eret, fetch.branch, fetch.jump, fetch.jr,
                      fetch.pcexception, fetch.epc, fetch.pcbranch, fetch.pcjump, fetch.pcjr, pcplus, 
                      pc_new, pc_upd);
    
    bpb_result_t last_predict, next_predict;                      
    logic fetch_commit_conflict;                             
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    pc <= 32'Hbfc00000;
                    last_predict <= '0;
                    fetch_commit_conflict <= 'b0;
                end
            else
                begin
                    if (flushF)
                        pc <= '0;
                    else
                        if ((~stallF & ~fetch_commit_conflict) | pc_upd)
                            begin
                                pc <= pc_new;
                                last_predict <= (pc_upd) ? ('0) : (next_predict);
                            end                                
                        else
                            pc <= pc;
                            
                    if (pc_upd)
                        fetch_commit_conflict = 'b1;
                    if (dataOK)
                        fetch_commit_conflict = 'b0;
                end
        end                                         
    
    assign ien = {1'b1, hit};
    assign hitF = ien;
    assign addr = pc;
    assign instr = data;
    
    logic exception_instr;
    adder#(32) pcadder4(pc, 32'b0100, pcplus4);
    adder#(32) pcadder8(pc, 32'b1000, pcplus8);
    assign exception_instr = (pcplus4[1:0] != '0);
    
    // assign {dataF[1].exception_instr, dataF[0].exception_instr} = {exception_instr, exception_instr};
    
    assign fetch_data[1].instr_ = instr[0];
    assign fetch_data[0].instr_ = (last_predict.taken) ? ('0) : (instr[1]);
    assign fetch_data[1].pcplus4 = pcplus4;
    assign fetch_data[0].pcplus4 = pcplus8;
    assign fetch_data[1].en = 1'b1;
    assign fetch_data[0].en = ien[0] & (~last_predict.taken);
    assign fetch_data[1].exception_instr = exception_instr;
    assign fetch_data[0].exception_instr = exception_instr;
    assign fetch_data[1].pred = destpc_predictF[1].taken;
    assign fetch_data[0].pred = destpc_predictF[0].taken & ien[0];
    assign finishF = dataOK && ~fetch_commit_conflict;    
    //to decode
    
    assign pc_predictF = {pc, pcplus4};
    assign pcplus = (last_predict.taken)                ? (last_predict.destpc)       :(
                    (destpc_predictF[1].taken & ien[0]) ? (destpc_predictF[1].destpc) :(
                    (ien[0])                            ? (pcplus8)                   : (pcplus4)));
    assign next_predict = (ien[1] & ~ien[0])            ? (destpc_predictF[1])        : (
                          (ien[0])                      ? (destpc_predictF[0])        : ('0));
    
endmodule
