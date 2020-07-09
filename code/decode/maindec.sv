`include "mips.svh"
module maindec (
    input word_t instr,
    output decoded_op_t op,
    output logic exception_ri
    // output control_t ctl
);
    op_t op_;
    assign op_ = op_t'(instr[31:26]);

    func_t func;
    assign func = instr[5:0];
    always_comb begin
        exception_ri = 1'b0;
        // ctl = '0;
        case (op_)
            `OP_ADDI: begin
                op = ADD;
                // alufunc = ALU_ADD;
                // ctl.regwrite = 1'b1;
                // ctl.alusrc = IMM;
                // ctl.regdst = RT;
            end  
            `OP_ADDIU: begin
                op = ADDU;
                // alufunc = ALU_ADDU;
                // ctl.regwrite = 1'b1;
                // ctl.alusrc = IMM;
                // ctl.regdst = RT;
            end 
            `OP_SLTI:  begin
                op = SLT;
                // alufunc = ALU_SLT;
                // regwrite = 1'b1;
                // shift = 1'b1;
                // alusrc = IMM;
                // regdst = RT;
            end 
            `OP_SLTIU: begin
                op = SLTU;
                // alufunc = ALU_SLT;
                // regwrite = 1'b1;
                // shift = 1'b1;
                // alusrc = IMM;
                // regdst = RT;
            end 
            `OP_ANDI: begin
                op = AND;
                // alufunc = ALU_AND;
                // regwrite = 1'b1;
                // zeroext = 1'b1;
                // alusrc = IMM;
                // regdst = RT;
            end  
            `OP_LUI:  begin
                op = LUI;
                // alufunc = ALU_SLL;
                // regwrite = 1'b1;
                // alusrc = IMM;
                // regdst = RT;
                // shift = 1'b1;
            end  
            `OP_ORI:  begin
                op = OR;
                // alufunc = ALU_OR;
                // regwrite = 1'b1;
                // alusrc = IMM;
                // regdst = RT;
                // zeroext = 1'b1;
            end  
            `OP_XORI: begin
                op = XOR;
                // alufunc = ALU_XOR;
                // regwrite = 1'b1;
                // alusrc = IMM;
                // regdst = RT;
                // zeroext = 1'b1;
            end  
            `OP_BEQ: begin
                op = BEQ;
                // alufunc = 
            end   
            `OP_BNE: begin
                op = BNE;
            end   
            `OP_BGEZ: begin
                case (instr[20:16])
                    `B_BGEZ:  begin
                        op = BGEZ;
                    end  
                    `B_BLTZ: begin
                        op = BLTZ;
                    end   
                    `B_BGEZAL: begin
                        op = BGEZAL;
                    end 
                    `B_BLTZAL: begin
                        op = BLTZAL;
                    end 
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            `OP_BGTZ: begin
                op = BGTZ;
            end  
            `OP_BLEZ: begin
                op = BLEZ;
            end  
            `OP_J: begin
                op = J;
            end     
            `OP_JAL: begin
                op = JAL;
            end   
            `OP_LB: begin
                op = LB;
            end    
            `OP_LBU: begin
                op = LBU;
            end   
            `OP_LH: begin
                op = LH;
            end    
            `OP_LHU: begin
                op = LHU;
            end   
            `OP_LW: begin
                op = LW;
            end    
            `OP_SB: begin
                op = SB;
            end    
            `OP_SH: begin
                op = SH;
            end    
            `OP_SW: begin
                op = SW;
            end    
            `OP_ERET: begin
                case (instr[25:21])
                    `C_ERET:begin
                        op = ERET;
                    end 
                    `C_MFC0:begin
                        op = MFC0;
                    end 
                    `C_MTC0:begin
                        op = MTC0;
                    end 
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            `OP_RT: begin
                case (func)
                    `F_ADD: begin
                        op = ADD;
                    end    
                    `F_ADDU: begin
                        op = ADDU;
                    end   
                    `F_SUB: begin
                        op = SUB;
                    end    
                    `F_SUBU: begin
                        op = SUBU;
                    end   
                    `F_SLT: begin
                        op = SLT;
                    end    
                    `F_SLTU: begin
                        op = SLTU;
                    end   
                    `F_DIV: begin
                        op = DIV;
                    end    
                    `F_DIVU: begin
                        op = DIVU;
                    end   
                    `F_MULT: begin
                        op = MULT;
                    end   
					`F_MULTU:begin
                        op = MULTU;
                    end	
					`F_AND:begin
                        op = AND;
                    end		
					`F_NOR:begin
                        op = NOR;
                    end		
					`F_OR:begin
                        op = OR;
                    end		
					`F_XOR:begin
                        op = XOR;
                    end		
					`F_SLLV:begin
                        op = SLLV;
                    end	
					`F_SLL:begin
                        op = SLL;
                    end		
					`F_SRAV:begin
                        op = SRAV;
                    end	
					`F_SRA:begin
                        op = SRA;
                    end		
					`F_SRLV:begin
                        op = SRLV;
                    end	
					`F_SRL:begin
                        op = SRL;
                    end		
					`F_JR:begin
                        op = JR;
                    end		
					`F_JALR:begin
                        op = JALR;
                    end	
					`F_MFHI:begin
                        op = MFHI;
                    end	
					`F_MFLO:begin
                        op = MFLO;
                    end	
					`F_MTHI:begin
                        op = MTHI;
                    end	
					`F_MTLO:begin
                        op = MTLO;
                    end	
					`F_BREAK:begin
                        op = BREAK;
                    end	
					`F_SYSCALL:begin
                        op = SYSCALL;
                    end	
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