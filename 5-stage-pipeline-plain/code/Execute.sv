`include "MiPS.svh"

module Execute(
        input logic [4: 0] Rs, Rt,
        input logic [31: 0] RegRd1, RegRd2,
		input logic [31: 0] Imm32,
        input logic [4: 0] WriteReg,
        input logic WriteRegEn,
        output logic [4: 0] WriteRegOut,
        output logic WriteRegEnOut,
        
        input logic [2: 0] Type, 
		input logic [4: 0] ALUCtrl,
		input logic [1: 0] Exception, 
		input logic [2: 0] Move, 
		input logic [4: 0] Memory,
		input logic [5: 0] Machine,
        output logic HILOWrite,
        output logic [2: 0] TypeOut,
        output logic [2: 0] MoveOut,
        output logic [4: 0] MemoryOut,
        output logic [5: 0] MachineOut,

        output logic OverflowException,
        output logic AddressException,

        output logic [31: 0] ALUOut,
        output logic [31: 0] ALUOutH, ALUOutL,
        
    );
    
    logic [31: 0] ALUOut, ALUOutH, ALUOutL;
    logic [31: 0] SourceAPC8, SourceAHL, HL, CP0, SourceA, SourceB;
    BiMux BiMuxPCPlus8(RegRd1, PCPlus8, (Type == 3'b010), SourceAPC8);
    BiMux BiMuxHL(HI, LO, Move[0], HL);
    BiMux BiMuxSCHL(HL, SourceAPC8, Move[2] & Move[1], SourceAHL);
    BiMux BiMuxHL(CP0Read, RegRd2, Machine[3], CP0);
    BiMux BiMuxSCCP0(SourceAHL, CP0, Machine[5], SourceA);
    BiMux BiMuxImm(RegRt, Imm32, (Type == 3'b001 || Type == 3'b100), SourceB);
    
    ALU ALU(SourceA, 
            SourceB,
            ALUCtrl,
            ALUOut, ALUOutH, ALUOutL,
            OverflowException
            );
    assign AddressException = (Memory[4]) & ((ALUOut[0] != 0) | (ALUOut[1] != 0 && Memory[0] == 1) | (ALUOut[2] != 0 && Memory[1] == 1));
    
    assign RtOut = Rt;
    assign RdOut = Rd;
    assign MoveOut = Move;
    assign MemoryOut = Memory;
    assign MachineOut = Machine;    
endmodule