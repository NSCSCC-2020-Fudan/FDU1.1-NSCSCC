`include "MIPS.h"

module Memory(
        input logic [4: 0] Rt, Rd,
        input logic [31: 0] RegRd1, RegRd2,
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

        output logic MemoryEn,
        output logic [1: 0] Mode,
        output logic [31: 0] Addr,
        output logic MemWriteEn,
        output logic [31: 0] MemoryWrite,
        input logic [31: 0] MemoryRead,

        output logic [31: 0] Result
    );

    assign MemoryEn = Memory[4];
    assign Mode = Memory[2: 1];
    assign Addr = ALUOut;
    assign MemWriteEn = Memory[3];
    assign MemoryWrite = RegRd1;

    logic [31: 0] Data8, Data16, Data32, MemoryData;
    Extend Extend8 (MemoryRead[7: 0], MemoryExtend, Data8);
    Extend Extend16 (MemoryRead[15: 0], MemoryExtend, Data16);
    assign Data32 = MemoryRead;
    always @(*)
        begin
            case (Mode)
                2'b00: Data = Data8;
                2'b01: Data = Data16;
                2'b11: Data = Data32;
                default: Data = 32'b0;
            endcase
        end

    assign HIOut = ALUOutH;
    assign LOOut = ALUOutL;
    assign Result = (Memory[4]) ? (Data) : (ALUOut);

    assign MoveOut = Move;
    assign MemoryOut = Memory;
    assign MachineOut = Machine;
    assign RtOut = Rt;
    assign RdOut = Rd;
endmodule
