`include "mips.svh"

module branchpredict(
        input logic clk, reset, stall,
        input word_t [1: 0] pc_predict,
        output bpb_result_t [1: 0] destpc_predict,
        input word_t pc_commit,
        input logic wen,
        input bpb_result_t destpc_commit
    );
    
    logic [1: 0] hit0, hit1, hit2;
    bpb_result_t [1: 0] destpc_predict0, destpc_predict1, destpc_predict2; 
    
    word_t [1: 0] pcjump;
    logic [1: 0] jump, branch;
    
    bpb0 bpb0(clk, reset, stall,
              pc_predict,
              hit0, destpc_predict0,
              pc_commit,
              wen,
              destpc_commit);
    /*     
    bpb1 bpb1(clk, reset, stall,
              pc_predict,
              hit1, destpc_predict1,
              pc_commit,
              wen,
              destpc_commit);
         
    bpb2 bpb2(clk, reset, stall,
              pc_predict,
              hit2, destpc_predict2,
              pc_commit,
              wen,
              destpc_commit);   
    
    assign pc_predict[0] = (hit2[0])    ? (destpc_predict2[0]) : (
                           (hit1[0])    ? (destpc_predict1[0]) : (destpc_predict0[0]));
                           
    assign pc_predict[1] = (hit2[1])    ? (destpc_predict2[1]) : (
                           (hit1[1])    ? (destpc_predict1[1]) : (destpc_predict0[1]));                                          
    */
    
    assign destpc_predict[0] = (destpc_predict0[0]);
    assign destpc_predict[1] = (destpc_predict0[1]);
    
    //assign destpc_predict[0] = '0;
    //assign destpc_predict[1] = '0;
       
endmodule
