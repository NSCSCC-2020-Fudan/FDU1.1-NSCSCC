`include "MIPS.svh"

module Fetch(
        input logic clk,
        input logic Branch, JumpReg, Jump,
        input logic [31: 0] PCBranch, PCJumpReg, PCJump,
        output logic [31: 0] PC,
        output logic [31: 0] PCPlus4
    );

    logic [31: 0] PCJump_, PCJumpReg_, PCBranch_, PC_;
    
    BiMux BiMuxJump (PCPlus4, PCJump, Jump, PCJump_);
    BiMux BiMuxJumpReg (PCJump_, PCJumpReg, JumpReg, PCJumpReg_);
    BiMux BiMuxBranch (PCJumpReg_, PCBranch, Branch, PCBranch_);

    PCFile PCFile (clk, stull, reset,
                   PCBranch_, PC);
    
    assign PCPlus4 = PC + 3'b100;

endmodule