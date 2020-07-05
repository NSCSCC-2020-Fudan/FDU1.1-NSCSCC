`include "MIPS.svh"

module modulename(
        input logic clk, reset,
        
        output logic [31: 0] IAddr,
        input logic [31: 0] IRead,

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
    assign InstrF = IRead;

    Decode Decode(PCDIn, PCPlus4DIn,
                  InstrDIn,
                  BranchD, JumpRegD, JumpD,
                  PCBranchD, PCJumpD, PCJumpD,
                  RsD, RtD, RdD,
                  RegRd1, RegRd2,
                  Imm16D, Imm32D,
                  RegWriteEnD,
                  TypeD,
                  ALUCtrlD,
                  ExceptionD, MoveD,
                  MemoryD, MachineD
                  );
    
    Execute Execute(Rs, Rt, Rd,
                    RegRs, RegRt,
		            Imm16, Imm32,
                    RtOut, RdOut,
                    RegRsOut,

                    Type, 
		            ALUCtrl,
		            Move, 
		            Memory,
		            Machine,
                    HILOWrite,
                    TypeOut,
                    MoveOut,
                    MemoryOut,
                    MachineOut,

                    OverflowException,
                    AddressException,

                    ExRegisterEn,
                    ExRegister,
                    ExRegisterValue

                    ALUOut,
                    ALUOutH, ALUOutL,
                    );
    
    Hazard Hazard(

                  );

endmodule