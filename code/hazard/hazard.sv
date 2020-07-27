`include "interface.svh"
module hazard 
    import common::*;(
    hazard_intf.hazard self,
    input logic i_data_ok, d_data_ok
);
    logic stallF, stallD, stallR, stallI, stallE, stallC;
    logic         flushD, flushR, flushI, flushE, flushC;
    logic branch_taken, exception_valid, is_eret;
    logic rob_full;

    assign stallF = ~i_data_ok | rob_full;
    assign stallD = rob_full;
    assign stallR = rob_full;
    assign stallI = 1'b0;
    assign stallE = 1'b0;
    assign stallC = 1'b0;
    assign flushD = ~i_data_ok | branch_taken | exception_valid;
    assign flushR = branch_taken | exception_valid;
    assign flushE = branch_taken | exception_valid;
    assign flushI = branch_taken | exception_valid;
    assign flushC = branch_taken | exception_valid;

    // ports
    assign self.stallF = stallF;
    assign self.stallD = stallD;
    assign self.stallR = stallR;
    assign self.stallI = stallI;
    assign self.stallE = stallE;
    assign self.stallC = stallC;
    assign self.flushD = flushD;
    assign self.flushR = flushR;
    assign self.flushI = flushI;
    assign self.flushE = flushE;
    assign self.flushC = flushC;
    assign branch_taken = ports.branch_taken;
    assign exception_valid = ports.exception_valid;
    assign is_eret = ports.is_eret;
    assign rob_full = ports.rob_full;
endmodule