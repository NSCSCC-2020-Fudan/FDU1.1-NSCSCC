`include "MIPS.svh"

module Decode(
        input logic clk, stall, reset,
        input logic [31: 0] PCPlus4,
        input logic [31: 0] Instr,
        
        output logic Branch, JumpReg, Jump,
        output logic [31: 0] PCBranch, PCJumpReg, PCJump,
        
        output logic [4: 0] RegR1, RegR2,
		input logic [31: 0] Reg
    );

    MainDec MainDec(Instr,
                	ALUCtrl, ALUMode,
		            Branch, JumpReg, Jump,
        		    Exception, 
             		Move, Memory,
             		Machine,
					Type
             		);
    ALUDec ALUDec(Type, 
				  Instr,
				  ALUCtrl, ALUMode
				 );

    logic [31: 0] ZeroExt, SignExt, ImmExt;
	assign Imm16 = Instr[15: 0];
	Extend SignExtend(Imm16, 0, SignExt);
    Extend ZeroExtend(Imm16, 1, ZeroExt);
	BiMux BiMuxExt(SignExt, ZeroExt, ((Type == 3'b001) & ((ALUCtrl == 4'b0101) | (ALUCtrl == 4'b0110) | (ALUCtrl == 4'b1000))), ImmExt);
	BiMux BiMuxLeft({Imm16, 16'b0}, ImmExt, ((Type == 3'b001) & (ALUCtrl == 4'b1111)), Imm32);
	
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