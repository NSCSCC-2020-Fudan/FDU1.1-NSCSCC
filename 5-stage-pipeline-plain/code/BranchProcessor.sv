`include "MIPS.svh"

module BrancProcessor(
        input logic [31: 0] PC,
        input logic [31: 0] Instr,
        input logic [31: 0] RegRs, RegRt
        input logic [4: 0] Branch,
        input logic [1: 0] JumpReg, Jump,
        output logic BranchF, JumpRegF, JumpF,
        output logic [31: 0] PCBranch, PCJumpReg, PCJump
    );

    logic [31: 0] idx, Offset;
    logic idx = Instr[25: 0];
    Extend SignExtend({Instr[15: 0], 2'b00}, 0, Offset);
    ADDer(PC, Offset, PCBranch);
    always @(*)
        begin
            BranchF <= Branch[4];
            case(Branch[3, 2])
                2'b00: BranchF <= (RegRs == RegRt);
                2'b01: BranchF <= !(RegRs == RegRt);
                2'b10: BranchF <= (Branch[0]) : (RegRs <= RegRt) ? (RegRs < RegRt);
                2'b11: BranchF <= (Branch[0]) : (RegRs >= RegRt) ? (RegRs > RegRt);
            endcase
        end

    assign PCJumpReg = RegRd;
    assign JumpRegF = JumpReg[1];

    assign PCJump = {PC[31: 28], Instr[25: 0], 2'b00};
    assign JumpF = Jump[1];
    
endmodule