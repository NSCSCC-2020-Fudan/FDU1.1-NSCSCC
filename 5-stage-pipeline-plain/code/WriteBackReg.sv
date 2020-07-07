`include "MIPS.svh"
module WriteBackReg(
        input logic clk, reset,
        input logic PrivilegeWriteMOut,
        input logic [4: 0] CP0RegWriteMOut,
        input logic [2: 0] CP0SelWriteMOut,
        input logic [31: 0] ResultMOut,
        input logic WriteRegEnMOut, 
        input logic [4: 0] WriteRegMOut,
		input logic HIWriteEnMOut, LOWriteEnMOut,
        input logic [31: 0] ALUOutHIMOut, ALUOutLOMOut,
        output logic PrivilegeWriteWIn,
        output logic [4: 0] CP0RegWriteWIn,
        output logic [2: 0] CP0SelWriteWIn, 
        output logic [31: 0] ResultWIn,
        output logic WriteRegEnWIn, 
        output logic [4: 0] WriteRegWIn,
        output logic HIWriteEnWIn, LOWriteEnWIn,
        output logic [31: 0] ALUHIWIn, ALULOWIn
    );
    
    Dtrigger PrivilegeWrite #(1) (clk, reset, 1'b0, 1'b0, PrivilegeWriteMOut, PrivilegeWriteWIn);
    Dtrigger CP0RegWrite #(5) (clk, reset, 1'b0, 1'b0, CP0RegWriteMOut, CP0RegWriteWIn);
    Dtrigger CP0SelWrite #(3) (clk, reset, 1'b0, 1'b0, CP0SelWriteMOut, CP0SelWriteWIn);
    Dtrigger Result #(32) (clk, reset, 1'b0, 1'b0, ResultMOut, ResultWIn);
    Dtrigger WriteRegEn #(1) (clk, reset, 1'b0, 1'b0, WriteRegEnMOut, WriteRegEnWIn);
    Dtrigger WriteReg #(5) (clk, reset, 1'b0, 1'b0, WriteRegMOut, WriteRegWIn);
    Dtrigger HIWriteEn #(1) (clk, reset, 1'b0, 1'b0, HIWriteEnMOut, HIWriteEnWIn);
    Dtrigger LOWriteEn #(1) (clk, reset, 1'b0, 1'b0, LOWriteEnMOut, LOWriteEnWIn);
    Dtrigger ALOHI #(32) (clk, reset, 1'b0, 1'b0, ALUOutHIMOut, ALUHIWIn);
    Dtrigger ALOLO #(32) (clk, reset, 1'b0, 1'b0, ALUOutLOMOut, ALULOWIn);
endmodule