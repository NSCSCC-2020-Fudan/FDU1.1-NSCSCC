`include "mips.svh"

module bpb1(
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
    logic [`BPB_GLOBAL_WIDTH1 - 1: 0] history;
    always_ff @(posedge clk)
        begin
            if (~reset)
                history <= '0;
            else
                if (wen)
                    history <= {destpc_commit.taken};
        end
    
    word_t pc0, pc1, pc2;
    assign pc0 = pc_predict[0];
    assign pc1 = pc_predict[1];
    assign pc2 = pc_commit;
    logic [`BPB_ENTRY_WIDTH - 1: 0] entry_commit, entry_predict0, entry_predict1;
    assign entry_commit = {pc2[`BPB_ENTRY_WIDTH1 - 1: 0]};
    assign entry_predict0 = {pc0[`BPB_ENTRY_WIDTH1 - 1: 0]};
    assign entry_predict1 = {pc1[`BPB_ENTRY_WIDTH1 - 1: 0]}; 
    
    genvar j;
    logic [1: 0] hit_set [`BPB_ENTRIES - 1: 0];
    bpb_result_t [`BPB_ENTRIES - 1: 0] destpc_predict_set;
    generate 
        for (j = 0; j < `BPB_ENTRIES; j = j + 1) begin: bpb_set
            bpb_line1 bpb_line(clk, reset, stall,
                               pc_predict, 
                               hit_set[j], destpc_predict_set[j],
                               pc_commit,
                               wen && (entry_commit == j),
                               destpc_commit);
        end
    endgenerate        
    
    assign destpc_predict[1] = destpc_predict_set[entry_predict1];
    assign destpc_predict[0] = destpc_predict_set[entry_predict0];
    logic [1: 0] hit_, hit__;
    assign hit_ = hit_set[entry_predict1];
    assign hit__ = hit_set[entry_predict0];
    assign hit[1] = hit_[1]; 
    assign hit[0] = hit__[0];
    
endmodule
