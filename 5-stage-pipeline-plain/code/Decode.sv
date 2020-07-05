`include "MIPS.svh"

module Decode(
        input logic clk, reset,
		input logic [31: 0] PC,
        input logic [31: 0] PCPlus4,
        input logic [31: 0] Instr,
		output logic [31: 0] PCPlus4Out,
        
        output logic BranchF, JumpRegF, JumpF,
        output logic [31: 0] PCBranch, PCJumpReg, PCJump,

		output logic [4: 0] Rs, Rt, Rd,
		output logic [31: 0] RegRd1, RegRd2,
		output logic [15: 0] Imm16,
		output logic [31: 0] Imm32,

		output logic [2: 0] Type,
		output logic [4: 0] ALUCtrl,
		output logic [1: 0] Exception, 
		output logic [2: 0] Move, 
		output logic [4: 0] Memory,
		output logic [5: 0] Machine,

		output logic WriteRegEn,
		output logic [4: 0] WriteReg,
		output logic HIWriteEn, LOWriteEn,

		input logic WriteRegEnW, 
		input logic [4: 0] WriteRegW, 
		input logic [31: 0] WeiteDataW,
		input logic HIWriteEnW, LOWriteEnW,
        input logic [31: 0] HIWriteDataW, LOWriteDataW,
    );

	RegFile RegFile(clk, reset,
					Rs, Rt,
					RegRd1, RegRd2,
					RegWriteEnW,
					WriteRegEnW, WriteRegW, WeiteDataW,
					HIWriteEnW, LOWriteEnW,
        			HIWriteDataW, LOWriteDataW,
        			HIRead, LORead
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
									RegRd1, RegRd2, 
									Branch, JumpReg, Jump,
									BranchF, JumpRegF, JumpF, 
									PCBranch, PCJump, PCJumpReg,
									);

	assign PCPlus4Out = PCPlus4;					
	assign WriteReg = (Type == 3'b000 || Type == 3'b011) ? (Rdd) : (Rs);

	logic RWrite, BJWrite;
	assign RWrite = (Type == 3'b000 && ALUCtrl[4: 1] != 4'b0011 && ALUCtrl[4: 1] != 4'b0110);
	assign BJWrite = (Instr[31: 25] == 6'b000001) || (Jump == 2'b11) || (JumpReg == 2'b11);
	assign WriteRegEn = RWrite || (Type == 3'b001) || BJWrite || (Move[3] & Move[2]) || (Memory[4] & Memory[3]) || (Machine[5] & Machine[3]);
	
	logic RWriteHL;
	assign RWriteHL = (Type == 3'b000 && ALUCtrl[4: 1] == 4'b0011 && ALUCtrl[4: 1] == 4'b0110);
	assign HIWriteEN = RWriteHL || (Move == 3'b110);
	assign LOWriteEN = RWriteHL || (Move == 3'b111);

endmodule