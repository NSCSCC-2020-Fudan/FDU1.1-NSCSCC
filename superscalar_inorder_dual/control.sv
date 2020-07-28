`include "mips.svh"

module control(
        input logic finishF, finishE, finishC, data_hazardI, queue_ofI, pcF,
        input logic is_eret, exception_valid,
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
    
    assign stallI = hazardC | hazardE | hazardI;
    assign stallE = hazardC | hazardE;
    assign stallC = hazardC;
    assign stallR = 'b0;
    
    assign flushD = (~finishF & ~queue_ofI) | pcF | flush_ex;
    assign stallD = queue_ofI;
    assign stallF = ~finishF | queue_ofI;
    
    assign pc_new_commit = pcF | flush_ex;
    
endmodule