`include "MiPS.svh"

module Execute(
        input logic [4: 0] Rs, Rt, Rd,
        input logic [31: 0] RegRs, RegRt,
		input logic [15: 0] Imm16,
		input logic [31: 0] Imm32,
        output logic [4: 0] RtOut, RdOut,
        output logic [31: 0] RegRsOut,

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

        output logic ExRegisterEn,
        output logic [1: 0] ExRegister,
        input logic [31: 0] ExRegisterValue

        output logic [31: 0] ALUOut,
        output logic [31: 0] ALUOutH, ALUOutL,
        
    );
    
    logic [31: 0] ALUOutH, ALUOutL;
    ALU ALU(
            RegRs, 
            ((Type == 3'b001) || (Type == 100)) ? Imm32 : RegRt,
            ALUCtrl, 
            ALUOutH, ALUOutL,
            OverflowException
            );
    assign HILOWrite = ((ALUCtrl[4: 1] == 4'b0100) || (ALUCtrl[4: 1] == 4'b0011));
    assign AddressException = (Memory[4]) & ((ALUOutH[0] != 0) | (ALUOutH[1] != 0 && Memory[0] == 1) | (ALUOutH[2] != 0 && Memory[1] == 1));
    
    assign ExRegisterEn = Move[2];
    assign ExRegister = Move[0];

    assign ALUOut = (ExRegisterEn) ? (ExRegisterValue) : (ALUOutH);
    
    assign RtOut = Rt;
    assign RdOut = Rd;
    assign MoveOut = Move;
    assign MemoryOut = Memory;
    assign MachineOut = Machine;
endmodule