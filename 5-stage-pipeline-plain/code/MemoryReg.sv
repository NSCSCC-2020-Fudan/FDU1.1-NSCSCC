`include"MIPS.svh"
module MemoryReg MemoryReg(
        input logic clk, reset,
        input logic WriteRegEnEOut, 
        input logic [4: 0] WriteRegEOut,
        input logic HIWriteEnEout, LOWriteEnEout,
        input logic PrivilegeWriteEOut, 
        input logic [4: 0] CP0RegWriteEOut, 
        input logic [2: 0] CP0SelWriteEOut,            
        input logic [31: 0] RegRd1EOut, 
        input logic [4: 0] MemoryEOut,
        input logic [31: 0] ALUOutEOut, ALUOutHIEOut, ALUOutLOEOut,
        output logic WriteRegEnMIn, 
        output logic [4: 0] WriteRegMIn,
        output logic HIWriteEnMIn, LOWriteEnMIn,
        output logic PrivilegeWriteMIn, 
        output logic [4: 0] CP0RegWriteMIn,
        output logic [2: 0] CP0SelWriteMIn,            
        output logic [31: 0] RegRd1MIn, 
        output logic [4: 0] MemoryMIn,
        output logic [31 0] ALUOutMIn, ALUOutHIMIn, ALUOutLOMIn
    );

    Dtrigger WriteRegEn #(1) (clk, reset, 1'b0, 1'b0, WriteRegEnEOut, WriteRegEnMIn);
    Dtrigger WriteReg #(5) (clk, reset, 1'b0, 1'b0, WriteRegEOut, WriteRegMIn);
    Dtrigger HIWriteEn #(1) (clk, reset, 1'b0, 1'b0, HIWriteEnEout, HIWriteEnMIn);
    Dtrigger LOWriteEn #(1) (clk, reset, 1'b0, 1'b0, LOWriteEnEout, LOWriteEnMIn);
    Dtrigger PrivilegeWrite #(1) (clk, reset, 1'b0, 1'b0, PrivilegeWriteEOut, PrivilegeWriteMIn);
    Dtrigger CP0RegWrite #(5) (clk, reset, 1'b0, 1'b0, CP0RegWriteEOut, CP0RegWriteMIn);
    Dtrigger CP0SelWrite #(3) (clk, reset, 1'b0, 1'b0, CP0SelWriteEOut, CP0SelWriteMIn);
    Dtrigger RegRd1 #(32) (clk, reset, 1'b0, 1'b0, RegRd1EOut, RegRd1MIn);
    Dtrigger Memory #(5) (clk, reset, 1'b0, 1'b0, MemoryEOut, MemoryMIn);
    Dtrigger ALUOut #(32) (clk, reset, 1'b0, 1'b0, ALUOutEOut, ALUOutHIMIn);
    Dtrigger ALUOutHI #(32) (clk, reset, 1'b0, 1'b0, ALUOutHIEOut, ALUOutHIMIn);
    Dtrigger ALUOutLO #(32) (clk, reset, 1'b0, 1'b0, ALUOutLOEOut, ALUOutLOMIn);
    
endmodule