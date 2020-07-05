`include "MIPS.h"

module Decode(
        input logic clk, stall, reset,
        input logic [31: 0] PCPlus4,
        input logic [31: 0] Instr,
        
        output logic Branch, JumpReg, Jump,
        output logic [31: 0] PCBranch, PCJumpReg, PCJump,
        
    );

    MainDec(Instr,
            ALUCtrl, ALUMode,
            BranchInstr, JumpReg, Jump
            );

    logic [31: 0] ZeroExt, SignExt;

    Extend ZeroExtend(Insrt[25: 0], 0, ZeroExt);
    Extend SignExtend(Instr[25: 0], 1, ZeroExt);
    
    logic [31: 0] BranchOffset;
    assign PCJump = {PC[31, 28], Instr[25, 0], 2'b00};
    assign JumpReg = {};

    Extend BranchExtend({Instr, 2'b00}, 1, Offsetset);
    Adder BranchAdder(PCPlus4, BranchOffset);


    
endmodule