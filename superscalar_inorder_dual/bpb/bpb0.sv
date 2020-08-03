`include "mips.svh"

module bpb0(
        input logic clk, reset, stall,
        input word_t [1: 0] pc_predict,
        output logic [1: 0] hit,
        output bpb_result_t [1: 0] destpc_predict,
        input word_t pc_commit,
        input logic wen,
        input bpb_result_t destpc_commit
    );
    
    logic [`BPB_ENTRY_WIDTH - 1: 0] i;
    logic [`BPB_ENTRY_WIDTH - 1: 0] entry_id [`BPB_ENTRIES - 1: 0];
    
    word_t pc0, pc1, pc2;
    assign pc0 = pc_predict[0];
    assign pc1 = pc_predict[1];
    assign pc2 = pc_commit;
    logic [`BPB_ENTRY_WIDTH - 1: 0] entry_commit, entry_predict0, entry_predict1;
    assign entry_commit = {pc2[`BPB_ENTRY_WIDTH0 + 1: 2]};
    assign entry_predict0 = {pc0[`BPB_ENTRY_WIDTH0 + 1: 2]};
    assign entry_predict1 = {pc1[`BPB_ENTRY_WIDTH0 + 1: 2]}; 
    
    logic [1: 0] hit_set [`BPB_ENTRIES - 1: 0];
    bpb_result_t [1: 0] destpc_predict_set [`BPB_ENTRIES - 1: 0];
    
    genvar j;
    generate 
        for (j = 0; j < `BPB_ENTRIES; j = j + 1) begin: bpb_set
            bpb_line0 bpb_line(clk, reset, stall,
                               pc_predict, 
                               hit_set[j], destpc_predict_set[j],
                               pc_commit,
                               wen && (entry_commit == j),
                               //destpc_commit.taken
                               destpc_commit);
        end
    endgenerate        
    
    bpb_result_t [1: 0] destpc_predict_, destpc_predict__;
    assign destpc_predict_ = destpc_predict_set[entry_predict1];
    assign destpc_predict__ = destpc_predict_set[entry_predict0];
    assign destpc_predict[1] = destpc_predict_[1];
    assign destpc_predict[0] = destpc_predict__[0];
    
    logic [1: 0] hit_, hit__;
    assign hit_ = hit_set[entry_predict1];
    assign hit__ = hit_set[entry_predict0];
    assign hit[1] = hit_[1]; 
    assign hit[0] = hit__[0];
    
endmodule
