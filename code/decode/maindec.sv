`include "mips.svh"
module maindec (
    input word_t instr,
    output decoded_op_t op,
    output logic exception_ri
);
    op_t op_;
    assign op_ = op_t'(instr[31:26]);

    func_t func;
    assign func = instr[5:0];
    always_comb begin
        exception_ri = 1'b0;
        case (op_)
            `OP_ADDI:   op = ADD;
            `OP_ADDIU:  op = ADDU;
            `OP_SLTI:   op = SLT;
            `OP_SLTIU:  op = SLTU;
            `OP_ANDI:   op = AND;
            `OP_LUI:    op = LUI;
            `OP_ORI:    op = OR;
            `OP_XORI:   op = XOR;
            `OP_BEQ:    op = BEQ;
            `OP_BNE:    op = BNE;
            `OP_BGEZ: begin
                case (instr[20:16])
                    `B_BGEZ:    op = BGEZ;
                    `B_BLTZ:    op = BLTZ;
                    `B_BGEZAL:  op = BGEZAL;
                    `B_BLTZAL:  op = BLTZAL;
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            `OP_BGTZ:   op = BGTZ;
            `OP_BLEZ:   op = BLEZ;
            `OP_J:      op = J;
            `OP_JAL:    op = JAL;
            `OP_LB:     op = LB;
            `OP_LBU:    op = LBU;
            `OP_LH:     op = LH;
            `OP_LHU:    op = LHU;
            `OP_LW:     op = LW;
            `OP_SB:     op = SB;
            `OP_SH:     op = SH;
            `OP_SW:     op = SW;
            `OP_ERET: begin
                case (instr[25:21])
                    `C_ERET: op = ERET;
                    `C_MFC0: op = MFC0;
                    `C_MTC0: op = MTC0;
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            `OP_RT: begin
                case (func)
                    `F_ADD:     op = ADD;
                    `F_ADDU:    op = ADDU;
                    `F_SUB:     op = SUB;
                    `F_SUBU:    op = SUBU;
                    `F_SLT:     op = SLT;
                    `F_SLTU:    op = SLTU;
                    `F_DIV:     op = DIV;
                    `F_DIVU:    op = DIVU;
                    `F_MULT:    op = MULT;
					`F_MULTU:	op = MULTU;
					`F_AND:		op = AND;
					`F_NOR:		op = NOR;
					`F_OR:		op = OR;
					`F_XOR:		op = XOR;
					`F_SLLV:	op = SLLV;
					`F_SLL:		op = SLL;
					`F_SRAV:	op = SRAV;
					`F_SRA:		op = SRA;
					`F_SRLV:	op = SRLV;
					`F_SRL:		op = SRL;
					`F_JR:		op = JR;
					`F_JALR:	op = JALR;
					`F_MFHI:	op = MFHI;
					`F_MFLO:	op = MFLO;
					`F_MTHI:	op = MTHI;
					`F_MTLO:	op = MTLO;
					`F_BREAK:	op = BREAK;
					`F_SYSCALL:	op = SYSCALL;
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            default: begin
                exception_ri = 1'b1;
                op = RESERVED;
            end
        endcase
	end
endmodule