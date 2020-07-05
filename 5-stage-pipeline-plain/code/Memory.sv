`include "MIPS.h"

module Memory(
        input logic [4: 0] Rt, Rd,
        input logic [31: 0] RegRs,
        output logic [4: 0] RtOut, RdOut,
        
        input logic HILOWrite,
        output logic HILOWriteOut,

        input logic [2: 0] Type,
        input logic [3: 0] Move,
        input logic [4: 0] Memory,
        inout logic [5: 0] Machine,
        input logic [31: 0] ALUOut,
        input logic [31: 0] ALUOutH, ALUOutL,
        output logic [3: 0] Move,
        output logic [4: 0] Memory,
        output logic [5: 0] Machine,
        output logic [31: 0] HIOut, LOOut,

        output logic [1: 0] Mode,
        output logic [31: 0] Addr,
        output logic MemWriteEn,
        output logic MemoryExtend,
        output logic [31: 0] MemoryWrite,
        input logic [31: 0] MemoryRead,

        output logic [31: 0] Result,
    );

    assign Mode = Memory[2: 1];
    assign Addr = ALUOut;
    assign MemWriteEn = Memory[3];
    assign MemoryExtend = Memory[0];
    assign MemoryWrite = RegRs;

    assign HIOut = ALUOutH;
    assign LOOut = ALUOutL;
    assign Result = (Memory[4]) ? (MemoryRead) : (ALUOut);

    assign MoveOut = Move;
    assign MemoryOut = Memory;
    assign MachineOut = Machine;
    assign RtOut = Rt;
    assign RdOut = Rd;
endmodule
