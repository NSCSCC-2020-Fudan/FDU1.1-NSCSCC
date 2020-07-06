`include "MIPS.svh"

module modulename(
        input logic clk, reset,
        
        output logic [31: 0] IAddr,
        input logic [31: 0] IRead,

        output logic DEn,
        output logic [1: 0] DMode,
        output logic [31: 0] DAddr,
        input logic [31: 0] DRead,
        output logic DWriteEN,
        output logic [31: 0] DWrite 
    );
    
    
    Fetch Fetch(clk,
                BranchD, JumpRegD, JumpD,
                PCBranchD, PCJumpRegD, PCJumpD,
                PCF, PCPlus4F,
                InstrF
                );
    assign IAddr = PCF;
    assign InstrF = IRead;DEn

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
                  PrivilegeRead, CP0RegRead, CP0SelRead, CP0Read,
		          PrivilegeWrite, CP0RegWrite, CP0SelWrite, CP0Write,
                  );
    
    Execute Execute(RsEIn, RtEIn,
                    RegRd1EIn, RegRd2EIn, Imm32EIn,
                    WriteRegEIn, WriteRegEnEIn,
                    WriteRegEOut, WriteRegEnEOut,                    
                    TypeEIn, ALUCtrlEIn, 
                    MoveEIn, MemoryEIn, MachineEIn, HILOWriteEIn,
                    TypeEOut,
                    MoveEOut, MemoryEOut, MachineEOut,
                    OverflowExceptionEOut, AddressExceptionEOut,
                    ALUOutEOut, ALUOutHEOut, ALUOutLEOut,
                    );

    Memory Memory(Rt, Rd,
                  RegRd1, RegRd2,
                  RtOut, RdOut,
                  HILOWrite, HILOWriteOut,
                  Type,
                  Move, Memory, Machine,
                  ALUOut,
                  ALUOutH, ALUOutL,
                  Move, Memory, Machine,
                  HIOut, LOOut,
                  DEn, DMode,
                  DAddr, DWriteEn, DWrite,
                  DRead,
                  Result);
    
    WriteBack WriteBack(clk, 

                        );
    
    Hazard Hazard(

                  );

endmodule