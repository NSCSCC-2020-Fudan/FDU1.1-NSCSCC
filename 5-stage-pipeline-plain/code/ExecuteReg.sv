`include"MIPS.svh"

module ExecuteReg(
        input logic clk, reset, stall, fush,
        input logic [4: 0] RsDOut, RtDOut,
        input logic [31: 0] RegRd1DOut, RegRd2DOut, Imm32DOut,
        input logic [2: 0] TypeDOut, 
        input logic [4: 0] ALUCtrlDOut, 
        input logic [1: 0] ExceptionDOut, 
        input logic [4: 0] MemoryDOut, 
        input logic [5: 0] MachineDOut,
        input logic [4: 0] WriteRegDOut, 
        input logic WriteRegEnDOut,
        input logic HIWriteEnDOut, LOWriteEnDOut,
        input logic PrivilegeWriteDOut, 
        input logic [4: 0] CP0RegWriteDOut, 
        input logic [2: 0] CP0SelWriteDOut,
        output logic [4: 0] RsEIn, RtEIn,
        output logic [31: 0] RegRd1EIn, RegRd2EIn, Imm32EIn,
        output logic [2: 0] TypeEIn, 
        output logic [4: 0] ALUCtrlEIn, 
        output logic [1: 0] ExceptionEIn, 
        output logic [4: 0] MemoryEIn, 
        output logic [5: 0] MachineEIn,
        output logic [4: 0] WriteRegEIn, 
        output logic WriteRegEnEIn,
        output logic HIWriteEnEIn, LOWriteEnEIn,
        output logic PrivilegeWriteEIn, 
        output logic [4: 0] CP0RegWriteEIn, 
        output logic [2: 0] CP0SelWriteEIn
    );

    Dtrigger Rs #(5) (clk, reset, stall, flush, RsDOut, RsEIn);
    Dtrigger Rt #(5) (clk, reset, stall, flush, RtDOut, RtEIn);
    Dtrigger RegRd1 #(32) (clk, reset, stall, flush, RegRd1DOut, RegRd1EIn);
    Dtrigger RegRd2 #(32) (clk, reset, stall, flush, RegRd2DOut, RegRd2EIn);
    Dtrigger Imm32 #(32) (clk, reset, stall, flush, Imm32DOut, Imm32EIn);
    Dtrigger Type #(3) (clk, reset, stall, flush, TypeDOut, TypeEIn);
    Dtrigger ALUCtrl #(5) (clk, reset, stall, flush, ALUCtrlDOut, ALUCtrlEIn);
    Dtrigger Exception #(2) (clk, reset, stall, flush, ExceptionDOut, ExceptionEIn);
    Dtrigger Memory #(5) (clk, reest, stall, flush, MemoryDOut, MemoryEIn);
    Dtrigger Machine #(6) (clk, reset, stall, flush, MachineDOut, MachineEIn);
    Dtrigger WriteReg #(5) (clk, reset, stall, flush, WriteRegDOut, WriteRegEIn);
    Dtrigger WriteRegEn #(1) (clk, reset, stall, flush, WriteRegEnDOut, WriteRegEnEIn);
    Dtrigger HIWriteEn #(1) (clk, reset, stall, flush, HIWriteEnDOut, HIWriteEnEIn);
    Dtrigger LOWriteEn #(1) (clk, reset, stall, flush, LOWriteEnDOut, LOWriteEnEIn);
    Dtrigger PrivilegeWrite #(1) (clk, reset, stall, flush, PrivilegeWriteDOut, PrivilegeWriteEIn);
    Dtrigger CP0RegWrite #(5) (clk, reset, stall, flush, CP0RegWriteDOut, CP0RegWriteEIn);
    Dtrigger CP0SelWrite #(3) (clk, reset, stall, flush, CP0RegWriteDOut, CP0RegWriteEIn);
    
endmodule