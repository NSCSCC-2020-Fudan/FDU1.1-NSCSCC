`include "MIPS.svh"

module Datapath(
        input logic clk, reset,
        
        output logic [31: 0] IAddr,
        input logic [31: 0] IRead,

        output logic DEn,
        output logic [1: 0] DMode,
        output logic [31: 0] DAddr,
        input logic [31: 0] DRead,
        output logic DWriteEN,
        output logic [31: 0] DWrite,

        output logic [4: 0] CP0RegRead, 
        output logic [2: 0] CP0SelRead,
        input logic [31: 0] CP0Read,

        output logic PrivilegeWrite,
        output logic [4: 0] CP0RegWrite, 
        output logic [2: 0] CP0SelRead,
        output logic [31: 0] CP0Write,
    );
    
    Fetch Fetch(clk, reset, stallF,
                PCFOut, PCPlus4FOut,
                BranchD, JumpRegD, JumpD,
                PCBranchD, PCJumpRegD, PCJumpD,
                InstrFIn, InstrFOut
                );
    assign IAddr = PCF;
    assign InstrFIn = IRead;

    DecodeReg DecodeReg(clk, reset, stallD, 
                        PCFOut, PCPlus4FOut,
                        PCDIn, PCPlus4DIn
                        );
    Decode Decode(clk, reset,
		          PCDIn, PCPlus4DIn, PCPlus4DOut,
                  IRead, 
                  BranchF, JumpRegF, JumpF,
                  PCBranch, PCJumpReg, PCJump,
		          RsDOut, RtDOut, RdDOut,
		          RegRd1DOut, RegRd2DOut, Imm32DOut,
	              TypeDOut, ALUCtrlDOut, ExceptionDOut, 
		          MoveDOut, MemoryDOut, MachineDOut,
		          WriteRegEnDOut, WriteRegDOut,
		          HIWriteEnDOut, LOWriteEnDOut, HIReadEnDOut, LOReadEnDOut,
		          WriteRegEnWOut, WriteRegWOut, ResultWOut,
		          HIWriteEnWOut, LOWriteEnWOut, ALUHIWOut, ALULOWOut,
		          PrivilegeWriteWOut, CP0RegWriteWOut, CP0SelWriteWOut, CP0WriteWOut,
                  PrivilegeReadDOut, CP0RegReadDOut, CP0SelReadDOut, CP0ReadDOut,
		          PrivilegeWriteDOut, CP0RegWriteDOut, CP0SelWriteDOut, CP0WriteDOut
                  );
    
    ExecuteReg ExecuteReg(clk, reset, stallE, flushEm
                          RsEIn, RtEIn,
                          RegRd1DOut, RegRd2DOut, Imm32DOut,
                          TypeEDOut, ALUCtrlDOut, 
                          ExceptionDOut, MemoryDOut, MachineDOut,
                          WriteRegDOut, WriteRegEnDOut,
                          HIWriteEnDOut, LOWriteEnDOut,
                          PrivilegeWriteDOut, CP0RegWriteDOut, CP0SelWriteDOut,
                          RsEIn, RtEIn,
                          RegRd1EIn, RegRd2EIn, Imm32EIn,
                          TypeEIn, ALUCtrlEIn, 
                          ExceptionEIn, MemoryEIn, MachineEIn,
                          WriteRegEIn, WriteRegEnEIn,
                          HIWriteEnEIn, LOWriteEnEIn,
                          PrivilegeWriteEIn, CP0RegWriteEIn, CP0SelWriteEIn,
                          );
    Execute Execute(RsEIn, RtEIn,
                    RegRd1EIn, RegRd2EIn, Imm32EIn,
                    RegRd1EOut,                 
                    TypeEIn, ALUCtrlEIn, 
                    ExceptionEIn, MemoryEIn, MachineEIn, MemoryEOut,
                    OverflowExceptionEOut, AddressExceptionEOut,
                    ALUOutEOut, ALUOutHIEOut, ALUOutLOEOut,
                    WriteRegEIn, WriteRegEnEIn,
                    WriteRegEOut, WriteRegEnEOut,   
                    HIWriteEnEIn, LOWriteEnEIn,
                    HIWriteEnEOut, LOWriteEnEOut,
                    PrivilegeWriteEIn,
                    CP0RegWriteEIn, CP0SelWriteEIn,
                    PrivilegeWriteEOut,
                    CP0RegWriteEOut, CP0SelWriteEOut
                    );

    MemoryReg MemoryReg(clk, reset,
                        WriteRegEnEOut, WriteRegEOut,
                        HIWriteEnEout, LOWriteEnEout,
                        PrivilegeWriteEOut, CP0RegWriteEOut, CP0SelWriteEOut,            
                        RegRd1EOut, MemoryEOut,
                        ALUOutEOut, ALUOutHIEOut, ALUOutLOEOut,
                        WriteRegEnMIn, WriteRegMIn,
                        HIWriteEnMIn, LOWriteEnMIn,
                        PrivilegeWriteMIn, CP0RegWriteMIn, CP0SelWriteMIn,            
                        RegRd1MIn, MemoryMIn,
                        ALUOutMIn, ALUOutHIMIn, ALUOutLOMIn
                        );
    Memory Memory(WriteRegEnMIn, WriteRegMIn,
                  WriteRegEnMOut, WriteRegMOut,
                  HIWriteEnMIn, LOWriteEnMIn,
                  HIWriteEnMOut, LOWriteEnMOut,
                  PrivilegeWriteMIn,
		          CP0RegWriteMIn, CP0SelWriteMIn,
                  PrivilegeWriteMOut,
		          CP0RegWriteMOut, CP0SelWriteMOut,
                  RegRd1MIn, MemoryMIn,
                  ALUOutMIn,
                  ALUOutHIMIn, ALUOutLOMIn,
                  ALUOutHIMOut, ALUOutLOMOut,
                  MemoryEnMOut, ModeMOut, AddrMOut,
                  MemWriteEnMOut, MemoryWriteMOut,
                  MemoryReadMIn,
                  ResultMOut
                  );
    
    WriteBackReg WriteBackReg(clk, reset,
                              PrivilegeWriteWIn,
                              CP0RegWriteMOut, CP0SelWriteMOut, ResultMOut,
                              WriteRegEnMOut, WriteRegMOut,
		                      HIWriteEnMOut, LOWriteEnMOut,
                              ALUOutHIMOut, ALUOutLOMOut,
                              PrivilegeWriteWIn,
                              CP0RegWriteWIn, CP0SelWriteWIn, ResultWIn,
                              WriteRegEnWIn, WriteRegWIn,
		                      HIWriteEnWIn, LOWriteEnWIn,
                              ALUHIWIn, ALULOWIn
                              );
    WriteBack WriteBack(PrivilegeWriteWIn,
		                CP0RegWriteWIn, CP0SelWriteWIn, ResultWIn,
                        PrivilegeWriteWOut,
                        CP0RegWriteWOut, CP0SelWriteWOut, ResultWOut,
                        WriteRegEnWIn, WriteRegWIn,
		                HIWriteEnWIn, LOWriteEnWIn,
                        ALUHIWIn, ALULOWIn,
                        WriteRegEnWOut, WriteRegWOut,
		                HIWriteEnWOut, LOWriteEnWOut,
                        ALUHIWOut, ALULOWOut
                        );
    
    Hazard Hazard(RsD, RtD
                  HIReadEnD, LOReadEnD,
                  PrivilegeReadD, CP0SelReadD,
                  WriteRegEnE, WriteRegE,
                  HIWriteEnE, LOWriteEnE,
                  PrivilegeWriteE, CP0RegWriteE, CP0SelWriteE,
                  WriteRegEnM, WriteRegM,
                  HIWriteEnM, LOWriteEnM,
                  PrivilegeWriteM, CP0RegWriteM, CP0SelWriteM,
                  DataHarzard
                  );

endmodule