`include "MIPS.h"

module WriteBack(
        input logic [4: 0] Rt, Rd,
        input logic [2: 0] Type, 
        input logic [2: 0] Move,
        input logic [4: 0] Memory,
        inout logic [31: 0] Result,

        inout logic HILOWrite,
        output logic [4: 0] RegWrite,
        output logic RegWriteEnOut,
        output logic [31: 0] RegResult,
        
        input logic [31: 0] HI, LO,
        output logic [31: 0] HIOut, LOOut,
        output logic [1: 0] HILOWriteEN,

        output logic [31: 0] MachineResult,
        output logic MachineWriteEn
    );

    assign RegWriteEnOut = RegWriteEn;    
    assign RegWrite = (Type == 3'b000) || (Type == 3'b001) || 
    assign HIOut = HI;
    assign LOOut = LO;
    assign HILOWriteEN[0] = (HILOWrite) || (Move == 3'b110);
    assign HILOWriteEN[1] = (HILOWrite) || (Move == 3'b111);

    assign RetResult = Result;
    assign MachineResult = Result;
endmodule
