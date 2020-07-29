`include "mips.svh"

/*
    state:
        00 -> 01 taken
        01 -> 11 taken  01 -> 00 not
        11 -> 10 not
        10 -> 11 taken  10 -> 00 not
*/

module bpb_line0( 
        input logic clk, reset, stall,
        input word_t [1: 0] pc_predict,
        output logic [1: 0] hit_predict,
        output bpb_result_t [1: 0] destpc_predict,
        input word_t pc_commit,
        input logic wen,
        input bpb_result_t destpc_commit                       
    );
    
    logic valid;
    word_t destpc;
    logic [1: 0] state;
    logic [`BPB_TAG_WIDTH0 - 1: 0] tag, tag_commit;
    assign tag_commit = pc_commit[31: 2 + `BPB_ENTRY_WIDTH0];
    
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    valid <= 1'b0;
                end
            else
                if (wen && ~stall)
                    begin
                        if (tag != tag_commit || ~valid)
                            begin
                                valid = 1'b1;
                                state = 2'b00;
                                tag = tag_commit;
                                destpc = destpc_commit.destpc;
                            end
                        case (state)
                            2'b00: state = (destpc_commit.taken) ? (2'b01) : (2'b00);
                            2'b01: state = (destpc_commit.taken) ? (2'b11) : (2'b00);
                            2'b10: state = (destpc_commit.taken) ? (2'b11) : (2'b00);
                            2'b11: state = (destpc_commit.taken) ? (2'b11) : (2'b10);                        
                        endcase
                    end              
        end
    
    word_t pc_predict1, pc_predict0;
    assign pc_predict1 = pc_predict[1];
    assign pc_predict0 = pc_predict[0];
    assign destpc_predict[1].taken = ((tag == pc_predict1[31: 2 + `BPB_ENTRY_WIDTH0]) ? (state[1]) : (1'b0)) & valid;
    assign destpc_predict[1].destpc = destpc;  
    assign destpc_predict[0].taken = ((tag == pc_predict0[31: 2 + `BPB_ENTRY_WIDTH0]) ? (state[1]) : (1'b0)) & valid;
    assign destpc_predict[0].destpc = destpc;
    assign hit_predict[1] = (tag == pc_predict1[31: 2 + `BPB_ENTRY_WIDTH0]) & valid;
    assign hit_predict[0] = (tag == pc_predict0[31: 2 + `BPB_ENTRY_WIDTH0]) & valid;
    
endmodule