`include "MIPS.svh"

module BrancProcessor(
        input logic [31: 0] PC,
        input logic [31: 0] Instr,
        input logic [31: 0] RegRd,
        input logic [4: 0] Branch,
        input logic [1: 0] JumpReg, Jump,
        output logic BranchF, JumpRegF, JumpF,
        output logic [31: 0] PCBranch, PCJumpReg, PCJump
    );

    logic [31: 0] idx, Offset;
    logic idx = Instr[25: 0];
    Extend SignExtend({Instr[15: 0], 2'b00}, 0, Offset);
    ADDer(PC, Offset, PCBranch);

    assign PCJumpReg = RegRd;
    assign JumpRegF = JumpReg[1];

    assign 
    
endmodule