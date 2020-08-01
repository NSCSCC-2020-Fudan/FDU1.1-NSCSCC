`include "interface.svh"
module hazard 
    import common::*;(
    hazard_intf.hazard self,
    input logic i_data_ok, d_data_ok,
    output logic flush
);
    logic stallF, stallD, stallR, stallI, stallE, stallC;
    logic         flushD, flushR, flushI, flushE, flushC;
    logic branch_taken, exception_valid, is_eret;
    logic rob_full, iq_full;

    assign stallF = (~i_data_ok | rob_full | iq_full);
    assign stallD = rob_full | iq_full;
    assign stallR = rob_full | iq_full;
    assign stallI = iq_full;
    assign stallE = 1'b0;
    assign stallC = 1'b0;
    assign flushD = ~i_data_ok | branch_taken | exception_valid;
    assign flushR = branch_taken | exception_valid;
    assign flushE = branch_taken | exception_valid;
    assign flushI = branch_taken | exception_valid | rob_full;
    assign flushC = branch_taken | exception_valid;
    assign flush = (branch_taken | exception_valid) &
                    ~stallF;

    // self
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
    assign branch_taken = self.branch_taken;
    assign exception_valid = 1'b0;
    assign is_eret = 1'b0;
    assign rob_full = self.rob_full;
    assign iq_full = self.iq_full;
endmodule