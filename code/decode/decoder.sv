module decoder 
    import common::*;
    import decode_pkg::*;(
    input word_t instr,
    output decoded_op_t op,
    output logic exception_ri,
    output control_t ctl
);
    op_t op_;
    assign op_ = instr[31:26];

    func_t func;
    assign func = instr[5:0];
    always_comb begin
        exception_ri = 1'b0;
        ctl = '0;
        case (op_)
            `OP_ADDI: begin
                op = ADD;
                ctl.alufunc = ALU_ADD;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.regdst = RT;
            end  
            `OP_ADDIU: begin
                op = ADDU;
                ctl.alufunc = ALU_ADDU;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.regdst = RT;
            end 
            `OP_SLTI:  begin
                op = SLT;
                ctl.alufunc = ALU_SLT;
                ctl.regwrite = 1'b1;
                
                ctl.alusrc = IMM;
                ctl.regdst = RT;
            end 
            `OP_SLTIU: begin
                op = SLTU;
                ctl.alufunc = ALU_SLTU;
                ctl.regwrite = 1'b1;
                
                ctl.alusrc = IMM;
                ctl.regdst = RT;
            end 
            `OP_ANDI: begin
                op = AND;
                ctl.alufunc = ALU_AND;
                ctl.regwrite = 1'b1;
                ctl.zeroext = 1'b1;
                ctl.alusrc = IMM;
                ctl.regdst = RT;
            end  
            `OP_LUI:  begin
                op = LUI;
                ctl.alufunc = ALU_LUI;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.regdst = RT;
            end  
            `OP_ORI:  begin
                op = OR;
                ctl.alufunc = ALU_OR;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.regdst = RT;
                ctl.zeroext = 1'b1;
            end  
            `OP_XORI: begin
                op = XOR;
                ctl.alufunc = ALU_XOR;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.regdst = RT;
                ctl.zeroext = 1'b1;
            end  
            `OP_BEQ: begin
                op = BEQ;
                ctl.branch = 1'b1;
                ctl.branch2 = 1'b1;
                ctl.branch_type = T_BEQ;
            end   
            `OP_BNE: begin
                op = BNE;
                ctl.branch = 1'b1;
                ctl.branch2 = 1'b1;
                ctl.branch_type = T_BNE;
            end   
            `OP_BGEZ: begin
                case (instr[20:16])
                    `B_BGEZ:  begin
                        op = BGEZ;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.branch_type = T_BGEZ;
                    end  
                    `B_BLTZ: begin
                        op = BLTZ;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.branch_type = T_BLTZ;
                    end   
                    `B_BGEZAL: begin
                        op = BGEZAL;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.branch_type = T_BGEZ;
                    end 
                    `B_BLTZAL: begin
                        op = BLTZAL;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.branch_type = T_BLTZ;
                    end 
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                    end
                endcase
            end
            `OP_BGTZ: begin
                op = BGTZ;
                ctl.branch = 1'b1;
                ctl.branch1 = 1'b1;
                ctl.branch_type = T_BGTZ;
            end  
            `OP_BLEZ: begin
                op = BLEZ;
                ctl.branch = 1'b1;
                ctl.branch1 = 1'b1;
                ctl.branch_type = T_BLEZ;
            end  
            `OP_J: begin
                op = J;
                ctl.jump = 1'b1;
            end     
            `OP_JAL: begin
                op = JAL;
                ctl.jump = 1'b1;
                ctl.regwrite = 1'b1;
            end   
            `OP_LB: begin
                op = LB;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.regdst = RT;
                ctl.alusrc = IMM;
            end    
            `OP_LBU: begin
                op = LBU;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.regdst = RT;
                ctl.alusrc = IMM;
            end   
            `OP_LH: begin
                op = LH;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.regdst = RT;
                ctl.alusrc = IMM;
            end    
            `OP_LHU: begin
                op = LHU;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.regdst = RT;
                ctl.alusrc = IMM;
            end   
            `OP_LW: begin
                op = LW;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.regdst = RT;
                ctl.alusrc = IMM;
            end    
            `OP_SB: begin
                op = SB;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
            end    
            `OP_SH: begin
                op = SH;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
            end    
            `OP_SW: begin
                op = SW;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
            end    
            `OP_ERET: begin
                case (instr[25:21])
                    `C_ERET:begin
                        op = ERET;
                        ctl.is_eret = 1'b1;
                    end 
                    `C_MFC0:begin
                        op = MFC0;
                        ctl.alufunc = ALU_PASSA;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RT;
                        ctl.cp0toreg = 1'b1;
                    end 
                    `C_MTC0:begin
                        op = MTC0;
                        ctl.cp0write = 1'b1;
                        ctl.alufunc = ALU_PASSB;
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
                        ctl.alufunc = ALU_ADD;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end    
                    `F_ADDU: begin
                        op = ADDU;
                        ctl.alufunc = ALU_ADDU;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end   
                    `F_SUB: begin
                        op = SUB;
                        ctl.alufunc = ALU_SUB;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end    
                    `F_SUBU: begin
                        op = SUBU;
                        ctl.alufunc = ALU_SUBU;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end   
                    `F_SLT: begin
                        op = SLT;
                        ctl.alufunc = ALU_SLT;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end    
                    `F_SLTU: begin
                        op = SLTU;
                        ctl.alufunc = ALU_SLTU;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end   
                    `F_DIV: begin
                        op = DIV;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                    end    
                    `F_DIVU: begin
                        op = DIVU;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                    end   
                    `F_MULT: begin
                        op = MULT;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                    end   
					`F_MULTU:begin
                        op = MULTU;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                    end	
					`F_AND:begin
                        op = AND;
                        ctl.alufunc = ALU_AND;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end		
					`F_NOR:begin
                        op = NOR;
                        ctl.alufunc = ALU_NOR;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end		
					`F_OR:begin
                        op = OR;
                        ctl.alufunc = ALU_OR;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end		
					`F_XOR:begin
                        op = XOR;
                        ctl.alufunc = ALU_XOR;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                    end		
					`F_SLLV:begin
                        op = SLLV;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;

                    end	
					`F_SLL:begin
                        op = SLL;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                        ctl.shamt_valid = 1'b1;
                    end		
					`F_SRAV:begin
                        op = SRAV;
                        ctl.alufunc = ALU_SRA;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                        
                    end	
					`F_SRA:begin
                        op = SRA;
                        ctl.alufunc = ALU_SRA;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                        ctl.shamt_valid = 1'b1;
                    end		
					`F_SRLV:begin
                        op = SRLV;
                        ctl.alufunc = ALU_SRL;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;

                    end	
					`F_SRL:begin
                        op = SRL;
                        ctl.alufunc = ALU_SRL;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alusrc = REGB;
                        ctl.shamt_valid = 1'b1;
                    end		
					`F_JR:begin
                        op = JR;
                        ctl.jump = 1'b1;
                        ctl.jr = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end		
					`F_JALR:begin
                        op = JALR;
                        ctl.jump = 1'b1;
                        ctl.jr = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end	
					`F_MFHI:begin
                        op = MFHI;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alufunc = ALU_PASSA;
                        ctl.hitoreg = 1'b1;
                    end	
					`F_MFLO:begin
                        op = MFLO;
                        ctl.regwrite = 1'b1;
                        ctl.regdst = RD;
                        ctl.alufunc = ALU_PASSA;
                        ctl.lotoreg = 1'b1;
                    end	
					`F_MTHI:begin
                        op = MTHI;
                        ctl.hiwrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end	
					`F_MTLO:begin
                        op = MTLO;
                        ctl.lowrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                    end	
					`F_BREAK:begin
                        op = BREAK;
                        ctl.alufunc = ALU_PASSA;
                        ctl.is_bp = 1'b1;
                    end	
					`F_SYSCALL:begin
                        op = SYSCALL;
                        ctl.alufunc = ALU_PASSA;
                        ctl.is_sys = 1'b1;
                    end	
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                        ctl.alufunc = ALU_PASSA;
                    end
                endcase
            end
            default: begin
                exception_ri = 1'b1;
                op = RESERVED;
                ctl.alufunc = ALU_PASSA;
            end
        endcase
	end
endmodule