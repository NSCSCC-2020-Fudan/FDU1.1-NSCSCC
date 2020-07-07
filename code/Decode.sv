`include "mips.svh"

module decode (
    Dreg_intf.out in,
    Ereg_intf.in out,
    rfi.decode rf
);
    op_t op;
    assign op = in.instr[31:26];

    func_t func;
    assign func = in.instr[5:0];

	decoded_instr_t di;
	assign di.rs = in.instr[25:21];
	assign di.rt = in.instr[20:16];
	assign di.rd = in.instr[15:11];
	assign di.ctl.alusrc = (op == `OP_RT) ? REG : IMM;
	assign di.ctl.regwrite = (op == `OP_RT) ? 1'b1 : 1'b0;
	assign di.ctl.memread = (di.op == LB) || (di.op == LBU) ||
							(di.op == LH) || (di.op == LHU) ||
							(di.op == LW) ||
							(di.op == SB) || (di.op == SH);
	assign di.ctl.memwrite = (di.op == SB) || (di.op == SW) || (di.op == SH);

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
                    `F_DIV:     di.op = DIV;
                    `F_DIVU:    di.op = DIVU;
                    `F_MULT:    di.op = MULT;
					`F_MULTU:	di.op = MULTU;
					`F_AND:		di.op = AND;
					`F_NOR:		di.op = NOR;
					`F_OR:		di.op = OR;
					`F_XOR:		di.op = XOR;
					`F_SLLV:	di.op = SLLV;
					`F_SLL:		di.op = SLL;
					`F_SRAV:	di.op = SRAV;
					`F_SRA:		di.op = SRA;
					`F_SRLV:	di.op = SRLV;
					`F_SRL:		di.op = SRL;
					`F_JR:		di.op = JR;
					`F_JALR:	di.op = JALR;
					`F_MFHI:	di.op = MFHI;
					`F_MFLO:	di.op = MFLO;
					`F_MTHI:	di.op = MTHI;
					`F_MTLO:	di.op = MTLO;
					`F_BREAK:	di.op = BREAK;
					`F_SYSCALL:	di.op = SYSCALL;
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
	
	aludec alude(di.op, di.ctl.alufunc);
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

module aludec (
	input decoded_op_t op,
	output alufunc_t alufunc
);
    always_comb begin
        case (op)
			ADD:		alufunc = ADD;
			ADDU:		alufunc = ADDU;
			SUB:		alufunc = SUB;
			SUBU:		alufunc = SUBU;
			SLT:		alufunc = SLT;
			SLTU:		alufunc = SLTU;
			AND:		alufunc = AND;
			NOR:		alufunc = NOR;
			OR:			alufunc = OR;
			XOR:		alufunc = XOR;
			SLLV:		alufunc = SLL;
			SLL:		alufunc = SLL;
			SRAV:		alufunc = SRA;
			SRA:		alufunc = SRA;
			SRLV:		alufunc = SRL;
			SRL:		alufunc = SRL;
			LUI:		alufunc = SLL;
			default: 	alufunc = ADDU;
        endcase
    end
endmodule