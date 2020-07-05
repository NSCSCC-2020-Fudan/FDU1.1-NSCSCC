`include "MIPS.h"

module Fetch(
        input logic clk,
<<<<<<< HEAD
        input logic [31: 0] PCJumpReg, PCBranch, PCJump,
        input logic JumpReg, Branch, Jump,
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
=======
        input logic [31: 0] PC,
        input logic [31: 0] RegJump, PCBranch, PCJump,
        input logic JumpReg, Branch, Jump,
    );

    
>>>>>>> f3e6f5489405c528c769f1ca9257a2f72d2ffca2

endmodule