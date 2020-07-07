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

        output logic PrivilegeRead,
        output logic [4: 0] CP0RegRead, 
        output logic [2: 0] CP0SelRead,
        input logic [31: 0] CP0Read,

        output logic PrivilegeWrite,
        output logic [4: 0] CP0RegWrite, 
        output logic [2: 0] CP0SelRead,
        output logic [31: 0] CP0Write,
    );
    
    
    Fetch Fetch(clk,
                BranchD, JumpRegD, JumpD,
                PCBranchD, PCJumpRegD, PCJumpD,
                PCF, PCPlus4F,
                InstrF
                );
    assign IAddr = PCF;
    assign InstrF = IRead;

    Decode Decode(clk, reset,
		          PC, PCPlus4DIn, PCPlus4DOut,
                  IRead, 
                  BranchF, JumpRegF, JumpF,
                  PCBranch, PCJumpReg, PCJump,
		          RsDOut, RtDOut, RdDOut,
		          RegRd1DOut, RegRd2DOut, Imm32DOut,
	              TypeDOut, ALUCtrlDOut, ExceptionDOut, 
		          MoveDOut, MemoryDOut, MachineDOut,
		          WriteRegEnDOut, WriteRegDOut,
		          HIWriteEnDOut, LOWriteEnDOut, HIReadEnDOut, LOReadEnDOut,
		          WriteRegEnWOut, WriteRegWOut, WeiteDataWOut,
		          HIWriteEnWOut, LOWriteEnWOut, HIWriteDataWOut, LOWriteDataWOut,
		          PrivilegeWriteWOut, CP0RegWriteWOut, CP0SelWriteWOut, CP0WriteWOut,
                  PrivilegeReadDOut, CP0RegReadDOut, CP0SelReadDOut, CP0ReadDOut,
		          PrivilegeWriteDOut, CP0RegWriteDOut, CP0SelWriteDOut, CP0WriteDOut
                  );
    
    Execute Execute(RsEIn, RtEIn,
                    RegRd1EIn, RegRd2EIn, Imm32EIn,
                    RetRd1EOut,                 
                    TypeEIn, ALUCtrlEIn, 
                    MoveEIn, MemoryEIn, MachineEIn, HILOWriteEIn,
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

    Memory Memory(HIWriteEnMIn, LOWriteEnMIn,
                  HIWriteEnMOut, LOWriteEnMOut,
                  PrivilegeWriteMIn,
		          CP0RegWriteMIn, CP0SelWriteMIn,
                  PrivilegeWriteMOut,
		          CP0RegWriteMOut, CP0SelWriteMOut,
                  RegRd1, Memory,
                  ALUOutMIn,
                  ALUOutHIMIn, ALUOutLOMIn,
                  ALUOutHIMOut, ALUOutLOMOut,
                  MemoryEnMOut, ModeMOut, AddrMOut,
                  MemWriteEnMOut, MemoryWriteMOut,
                  MemoryReadMIn,
                  ResultMOut
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
                        ALUHIOut, ALULOOut
                        );
    
    Hazard Hazard(
                
                  );

endmodule