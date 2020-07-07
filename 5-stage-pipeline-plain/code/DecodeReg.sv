`include "MIPS.svh"

module DecodeReg(
        input logic clk, reset, stall, flush,
        input logic [31: 0] PCFOut, PCPlus4FOut, InstrFOut,
        output logic [31: 0] PCDIn, PCPlus4DIn, InstrDIn
    );
    
    Dtrigger PC #(32) (clk, reset, stall, flush, PCFOut, PCDIn);
    Dtrigger PCPlus4 #(32) (clk, reset, stall, flush, PCPlus4FOut, PCPlus4DIn);
    Dtrigger Instr #(32) (clk, reset, stall, flush, InstrFOut, InstrDIn);

endmodule