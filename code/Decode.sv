`include "mips.svh"

module Decode (
    Dreg.out in,
    Ereg.in out,
    rfi.decode rf
);
    op_t op;
    assign op = in.instr[31:26];

    func_t func;
    assign func = in.instr[5:0];

    decoded_instr_t di;
    always_comb begin
        case (op)
            `OP_ADDI:   di.op = ADD;
            `OP_ADDIU:  di.op = ADDU;
            `OP_SLTI:   di.op = SLT;
            `OP_SLTIU:  di.op = SLTU;
            `OP_ANDI:   di.op = AND;
            `OP_LUI:    di.op = LUI;
            `OP_ORI:    di.op = OR;
            `OP_XORI:   di.op = XOR;
            `OP_BEQ:    di.op = BEQ;
            `OP_BNE:    di.op = BNE;
            `OP_BGEZ: begin
                case (instr[20:16])
                    `B_BGEZ:    di.op = BGEZ;
                    `B_BLTZ:    di.op = BLTZ;
                    `B_BGEZAL:  di.op = BGEZAL;
                    `B_BLTZAL:  di.op = BLTZAL;
                    default: begin
                        // reserved instruction exception;
                    end
                endcase
            end
            `OP_BGTZ:   di.op = BGTZ;
            `OP_BLEZ:   di.op = BLEZ;
            `OP_J:      di.op = J;
            `OP_JAL:    di.op = JAL;
            `OP_LB:     di.op = LB;
            `OP_LBU:    di.op = LBU;
            `OP_LH:     di.op = LH;
            `OP_LHU:    di.op = LHU;
            `OP_LW:     di.op = LW;
            `OP_SB:     di.op = SB;
            `OP_SH:     di.op = SH;
            `OP_SW:     di.op = SW;
            `OP_ERET: begin
                case (instr[25:21])
                    C_ERET: di.op = ERET;
                    C_MFC0: di.op = MFC0;
                    C_MTC0: di.op = MTC0;
                    default: begin
                        // reserved instruction exception
                    end
                endcase
            end
            `OP_RT: begin
                case (funct)
                    `F_ADD:     di.op = ADD;
                    `F_ADDU:    di.op = ADDU;
                    `F_SUB:     di.op = SUB;
                    `F_SUBU:    di.op = SUBU;
                    `F_SLT:     di.op = SLT;
                    `F_SLTU:    di.op = SLTU;

                    default: begin
                        // reserved instruction exception
                    end
                endcase
            end
            default: begin
                // reserved instruction exception;
            end
        endcase
    end
endmodule

// module MainDec (
//     input op_t op,
//     output control_t ctl
// );
//     always_comb begin
//         ctl = '0;
//         case (op)
//             `OP_ADDI : 


//             `OP_RT: begin
                
//             end
//             default: begin
//                 pass
//             end
//         endcase
//     end
// endmodule

// module ALUDec (
//     input func_t func,
//     input aluop_t aluop,
//     output alufunc_t alufunc
// );
//     always_comb begin
//         case (aluop)
            
//         endcase
//     end
// endmodule