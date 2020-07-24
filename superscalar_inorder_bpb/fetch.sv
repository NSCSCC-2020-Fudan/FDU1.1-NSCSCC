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
        input logic addrOK, dataOK,
        //to imem
        output fetch_data_t [1: 0] fetch_data,
        output logic [1: 0] hitF,
        output logic finishF,
        //to decode
        output word_t [1: 0] pc_predict,
        output word_t [1: 0] instr_predict,
        input bpb_result_t [1: 0] destpc_predict
    );
    
    logic [1: 0] state; 
    logic [1: 0] ien;
    word_t [1: 0] instr;
    word_t pcplus4, pcplus8, pcplus, pc_new;
    
    logic pc_upd;
    pcselect pcselect(fetch.exception_valid, fetch.is_eret, fetch.branch, fetch.jump, fetch.jr,
                      fetch.pcexception, fetch.epc, fetch.pcbranch, fetch.pcjump, fetch.pcjr, pcplus, 
                      pc_new, pc_upd);
    
    bpb_result_t last_predict, _last_predict;       
    logic addr_finish, fetch_commit_conflict;                            
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    pc <= 32'Hbfc00000;
                    addr_finish = 1'b1;
                    fetch_commit_conflict = 'b0;
                end
            else
                begin
                    if (flushF)
                        begin
                            pc <= 32'Hbfc00000;
                            addr_finish = 1'b1;
                            fetch_commit_conflict = 'b0;
                        end                            
                    else
                        if ((~stallF & ~fetch_commit_conflict) | pc_upd)
                            begin
                                pc <= pc_new;
                                last_predict = (pc_upd) ? ('0) : (_last_predict);                                         
                            end                            
                        else
                            pc <= pc;
                    
                    if (addrOK)
                        addr_finish = 1'b1;                                                    
                    if (pc_upd && addr_finish)
                        fetch_commit_conflict = 'b1;
                    if (dataOK)
                        begin
                            fetch_commit_conflict = 'b0;
                            addr_finish = 1'b0;
                        end
                end
        end                                         
    
    assign ien = {1'b1, hit};
    assign addr = pc;
    assign instr = data;
    
    fetch_data_t [1: 0] dataF;
    logic exception_instr;
    adder#(32) pcadder4(pc, 32'b0100, pcplus4);
    adder#(32) pcadder8(pc, 32'b1000, pcplus8);
    assign exception_instr = (pcplus4[1:0] != '0);
    
    // assign {dataF[1].exception_instr, dataF[0].exception_instr} = {exception_instr, exception_instr};
    
    
    assign pc_predict = {pc, pcplus4};
    assign instr_predict = {instr[0], instr[1]};
    logic [1: 0] taken_predict;
    assign taken_predict = {destpc_predict[1].taken, destpc_predict[0].taken};
    logic pcplus_predict;
    assign pcplus_predict = (destpc_predict[1].taken & hit);
    assign pcplus = (pcplus_predict)     ? (destpc_predict[1].destpc) : (
                    (last_predict.taken) ? (last_predict.destpc)      : (
                    (hit)                ? (pcplus8)                  : (pcplus4))); 
    assign _last_predict = (~hit & destpc_predict[1].taken) ? (destpc_predict[1]) : (                              
                           (hit & destpc_predict[0].taken)  ? (destpc_predict[0]) : ('0));
    assign hitF[1] = ien[1]; 
    assign hitF[0] = (hit & ~last_predict.taken);                 
                              
    
    assign fetch_data[1].instr_ = instr[0];
    assign fetch_data[0].instr_ = instr[1];
    assign fetch_data[1].pcplus4 = pcplus4;
    assign fetch_data[0].pcplus4 = pcplus8;
    assign fetch_data[1].en = hitF[1];
    assign fetch_data[0].en = hitF[0];
    assign fetch_data[1].exception_instr = exception_instr;
    assign fetch_data[0].exception_instr = exception_instr;
    assign fetch_data[1].pred = destpc_predict[1].taken;
    assign fetch_data[0].pred = destpc_predict[0].taken;
    assign finishF = dataOK && ~fetch_commit_conflict;
    
    
endmodule
