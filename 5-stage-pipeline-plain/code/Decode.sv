`include "MIPS.svh"

module Decode(
        input logic clk, stall, reset,
        input logic [31: 0] PCPlus4,
        input logic [31: 0] Instr,
        
        output logic BranchF, JumpRegF, JumpF,
        output logic [31: 0] PCBranch, PCJumpReg, PCJump,
        
        output logic [4: 0] RegR1, RegR2,
		input logic [31: 0] RegRd1, RegRd2,

		output logic [4: 0] Rs, Rt, Rd,
		output logic [15: 0] Imm16,
		output logic [31: 0] Imm32,

		output logic [2: 0] Type,
		output logic [4: 0] ALUCtrl,
		output logic [1: 0] Exception, 
		output logic [2: 0] Move, 
		output logic [4: 0] Memory,
		output logic [5: 0] Machine
    );

    MainDec MainDec(Instr,
		            Branch, JumpReg, Jump,
        		    Exception, 
             		Move, Memory,
             		Machine,
					Type
             		);
    ALUDec ALUDec(Type, 
				  Instr,
				  ALUCtrl
				 );

    logic [31: 0] ZeroExt, SignExt, ImmExt;
	assign Imm16 = Instr[15: 0];
	Extend SignExtend(Imm16, 0, SignExt);
    Extend ZeroExtend(Imm16, 1, ZeroExt);
	BiMux BiMuxExt(SignExt, ZeroExt, ((Type == 3'b001) & ((ALUCtrl[3: 1] == 4'b0101) | (ALUCtrl[3: 1] == 4'b0110) | (ALUCtrl[3: 1] == 4'b1000))), ImmExt);
	BiMux BiMuxLeft({Imm16, 16'b0}, ImmExt, ((Type == 3'b001) & (ALUCtrl[3: 1] == 4'b1111)), Imm32);
	
	assign Rs = Instr[25, 21];
	assign Rt = Instr[20, 16];
	assign Rd = Instr[15, 11];
    
    BranchPrecesser BranchProcessor(Instr,
									RdRs, 
									Branch, JumpReg, Jump,
									BranchF, JumpRegF, JumpF, 
									PCBranch, PCJump, PCJumpReg,
									);
endmodule