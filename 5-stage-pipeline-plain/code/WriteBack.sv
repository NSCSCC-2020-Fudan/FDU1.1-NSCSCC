`include "MIPS.h"
/*
    PrivilegeWrite: CP0 write enable
    CP0RegWrite: CP0 reg
    CP0SelWrite: CP0 sel
    Result: the data write back to register
    WriteRegEn: registers write enable
    HIWriteEn: HI register write enable
    LOWriteEn: LO register write enable
    ALUHI: HI comes from ALU
    ALULO: LO comes from ALU
*/

module WriteBack(
        input logic PrivilegeWrite,
		input logic [4: 0] CP0RegWrite,
		input logic [2: 0] CP0SelWrite,
		input logic [31: 0] Result,
        output logic PrivilegeWriteOut,
		output logic [4: 0] CP0RegWriteOut,
		output logic [2: 0] CP0SelWriteOut,
		output logic [31: 0] ResultOut,

        input logic WriteRegEn,
		input logic [4: 0] WriteReg,
		input logic HIWriteEn, LOWriteEn,
        input logic [31: 0] ALUHI, ALULO,
        output logic WriteRegEnOut,
		output logic [4: 0] WriteRegOut,
		output logic HIWriteEnOut, LOWriteEnOut,
        output logic [31: 0] ALUHIOut, ALULOOut
    );

    assign PrivilegeWriteOut = PrivilegeWrite;
    assign CP0RegWriteOut = CP0RegWrite;
    assign CP0SelWriteOut = CP0SelWrite;
    assign ResultOut = Result;

    assign WriteRegEnOut = WriteRegEn;
    assign WriteRegOut = WriteReg;
    assign HIWriteEnOut = HIWriteEn;
    assign LOWriteEnOut = LOWriteEn;
    assign ALUHIOut = ALUHI;
    assign ALULOOut = ALULO;
endmodule
