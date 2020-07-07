`include "MIPS.svh"

/*
	PCPlus4: PC + 4
	Instr: instruction to decode
	BranchF: branch or not
	JumpRegF: jr/jalr or not
	JumpF: j/jal or not
	PCBranch: branch target
	PCJumpReg: jr/jalr target
	PCJump: j/jal target
	Rs: register rs
	Rt: register rt
	Rd: register rd
	RegRd1: data in register 1
	RegRd2: data in register 2
	Imm32: immediate number / PC + 8
	Type: instruction type --MainDec.sv
	ALU Ctrl: ALU controller --ALUDec.sv
	Exception: exception instruction --MainDec.sv
	Move: exception instruction --MainDec.sv
	Memory: memory instruction --MainDec.sv
	Machine: machine instruction --MainDec.sv
	WriteRegEn: general register wirte enable
	WriteReg: general register to write
	HIWriteEn: HI register write enable
	LOWriteEn: LO register write enable
	HIReadEn: HI register read enable
	LOReadEn: LO register read enable
	PrivilegeRead: CP0 register read enable
	PrivilegeWrite: CP0 register write enable
	CP0Reg: CP0 reg to read
	CP0Sel: CP0 sel to read
	CP0Read: data read from CP0
*/

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
		output logic HIReadEn, LOReadEn,

		input logic WriteRegEnW, 
		input logic [4: 0] WriteRegW, 
		input logic [31: 0] WeiteDataW,
		input logic HIWriteEnW, LOWriteEnW,
        input logic [31: 0] HIWriteDataW, LOWriteDataW,

		output logic PrivilegeRead,
		output logic PrivilegeWrite,
		output logic [4: 0] CP0Reg,
		output logic [2: 0] CP0Sel,
		input logic [31: 0] CP0Read
    );

	logic [31: 0] HIRead, LORead, RegRds, RegRdt;
	RegFile RegFile(clk, reset,
					Rs, Rt,
					RegRds, RegRdt,
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

    logic [31: 0] ZeroExt, SignExt, ImmExt, Imm16, LUI, PCPlus8;
	assign Imm16 = Instr[15: 0];
	Extend SignExtend(Imm16, 0, SignExt);
    Extend ZeroExtend(Imm16, 1, ZeroExt);
	BiMux BiMuxExt(SignExt, ZeroExt, ((Type == 3'b001) & ((ALUCtrl[3: 1] == 4'b0101) | (ALUCtrl[3: 1] == 4'b0110) | (ALUCtrl[3: 1] == 4'b1000))), ImmExt);
	//I-type, And, Or, Xor
	BiMux BiMuxLUI(ImmExt, {Imm16, 16'b0}, (Instr[31: 26] == 6'b001111), LUI);
	//LUI
	Adder Adder8(PCPlus4, 3'b100, PCPlus8);
	BiMux BiMuxPlus8(LUI, PCPlus8, (Type == 3'b010), Imm32);
	//Imm32 <-- PCPlus8 jal/jalr

	logic [31: 0] RegRd1HI, RegRd1LO;
	assign Rs = Instr[25, 21];
	assign Rt = Instr[20, 16];
	assign Rd = Instr[15, 11];
	assign HIReadEn = (Move == 3'b100);
	assign LOReadEn = (Move == 3'b101);
	BiMux BiMuxHI(RegRds, HIRead, HIReadEn, RegRd1HI);
	BiMux BiMuxLO(RegRd1HI, LORead, LOReadEn, RegRd1LO);
	//RegRd1 <-- HI/LO/Rs
	logic RWriteHL;
	assign RWriteHL = (Type == 3'b000) && (ALUCtrl[4: 1] == 4'b0011 || ALUCtrl[4: 1] == 4'b0110);
	assign HIWriteEN = RWriteHL || (Move == 3'b110);
	assign LOWriteEN = RWriteHL || (Move == 3'b111);
	//HI/LO
    
    BranchPrecesser BranchProcessor(Instr,
									RegRd1, RegRd2, 
									Branch, JumpReg, Jump,
									BranchF, JumpRegF, JumpF, 
									PCBranch, PCJump, PCJumpReg,
									);
	//Branch/J/JR

	logic RWrite, BJWrite;
	assign RWrite = (Type == 3'b000 && ALUCtrl[4: 1] != 4'b0011 && ALUCtrl[4: 1] != 4'b0110);
	assign BJWrite = (Instr[31: 25] == 6'b000001) || (Jump == 2'b11) || (JumpReg == 2'b11);
	assign WriteRegEn = RWrite || (Type == 3'b001) || BJWrite || (Move[3] & Move[2]) || (Memory[4] & Memory[3]) || (Machine[5] & Machine[3]);
	logic [4: 0] WriteRegNoBJ;
	BiMux BiMuxNoBJ(Rs, Rd, (Type == 3'b000 || Type == 3'b011), WriteRegNoBJ);
	BiMux BiMuxBJ(WriteRegNoBJ, 5'b11111, BJWrite, WriteReg);
	//WriteReg
	
	assign PrivilegeRead = (Machine[5: 3] == 3'b100);
	assign CP0RegRead = Rd;
	assign CP0SelRead = Machine[2: 0];
	BiMux BiMuxCp0(RegRd1LO, CP0Read, PrivilegeRead, RegRd1);
	//RegRd1 <-- CP0
endmodule