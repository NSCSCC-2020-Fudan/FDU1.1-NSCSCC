`include "mips.svh"

module control(
        input logic clk, reset,
        input logic finishF, finishE, finishC, data_hazardI, queue_ofI, pcF,
        input logic is_eret, exception_valid, wait_ex,
        output logic stallF, stallD, flushD, stallI, flushI, 
        output logic stallE, flushE, stallC, flushC, stallR, flushR, pc_new_commit, flush_ex
    );
    
    assign flush_ex = (is_eret | exception_valid) & finishC;
    
    logic hazardC, hazardE, hazardI, hazardpc;
    assign hazardC = ~finishC;
    assign hazardE = ~finishE & finishC;
    assign hazardI = data_hazardI & finishE & finishC;

    assign flushI = pcF | flush_ex;
    assign flushE = hazardI | pcF | flush_ex;
    assign flushC = hazardE | (pcF & finishC) | flush_ex;
    assign flushR = hazardC;
    
    assign stallI = hazardC | hazardE | hazardI | wait_ex;
    assign stallE = hazardC | hazardE | wait_ex;
    assign stallC = hazardC | wait_ex;
    assign stallR = 'b0;
    
    assign flushD = (~finishF & ~queue_ofI) | pcF | flush_ex;
    assign stallD = queue_ofI;
    //assign stallF = ~finishF | queue_ofI;
    assign stallF = queue_ofI;
    
    assign pc_new_commit = pcF | flush_ex;
    
    int hazardC_count, hazardE_count, hazardI_count, hazardpc_count;
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    hazardC_count <= 0;
                    hazardE_count <= 0;
                    hazardI_count <= 0;
                    hazardpc_count <= 0;
                end
            else
                begin
                    hazardC_count <= (hazardC) ? (hazardI_count + 1) : (hazardC_count);
                    hazardE_count <= (hazardE) ? (hazardE_count + 1) : (hazardE_count);
                    hazardI_count <= (hazardI) ? (hazardC_count + 1) : (hazardI_count);
                    hazardpc_count <= (pc_new_commit) ? (hazardpc_count + 1) : (hazardpc_count);
                end
        end
    
endmodule