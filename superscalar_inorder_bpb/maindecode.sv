`include "mips.svh"

module maindecode (
        input word_t instr,
        input creg_addr_t rs, rt, rd,
        output decoded_op_t op,
        output logic exception_ri,
        output control_t ctl,
        output creg_addr_t srcrega, srcregb, destreg
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
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end  
            `OP_ADDIU: begin
                op = ADDU;
                ctl.alufunc = ALU_ADDU;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end 
            `OP_SLTI:  begin
                op = SLT;
                ctl.alufunc = ALU_SLT;
                ctl.regwrite = 1'b1;
                
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end 
            `OP_SLTIU: begin
                op = SLTU;
                ctl.alufunc = ALU_SLTU;
                ctl.regwrite = 1'b1;
                
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end 
            `OP_ANDI: begin
                op = AND;
                ctl.alufunc = ALU_AND;
                ctl.regwrite = 1'b1;
                ctl.zeroext = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end  
            `OP_LUI:  begin
                op = LUI;
                ctl.alufunc = ALU_LUI;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                srcrega = '0;
                srcregb = '0;
                destreg = rt;
            end  
            `OP_ORI:  begin
                op = OR;
                ctl.alufunc = ALU_OR;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.zeroext = 1'b1;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end  
            `OP_XORI: begin
                op = XOR;
                ctl.alufunc = ALU_XOR;
                ctl.regwrite = 1'b1;
                ctl.alusrc = IMM;
                ctl.zeroext = 1'b1;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end  
            `OP_BEQ: begin
                op = BEQ;
                ctl.branch = 1'b1;
                ctl.branch2 = 1'b1;
                ctl.branch_type = T_BEQ;
                srcrega = rs;
                srcregb = rt;
                destreg = '0;
            end   
            `OP_BNE: begin
                op = BNE;
                ctl.branch = 1'b1;
                ctl.branch2 = 1'b1;
                ctl.branch_type = T_BNE;
                srcrega = rs;
                srcregb = rt;
                destreg = '0;
            end   
            `OP_BGEZ: begin
                case (instr[20:16])
                    `B_BGEZ:  begin
                        op = BGEZ;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.branch_type = T_BGEZ;
                        srcrega = rs;
                        srcregb = '0;
                        destreg = '0;
                    end  
                    `B_BLTZ: begin
                        op = BLTZ;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.branch_type = T_BLTZ;
                        srcrega = rs;
                        srcregb = '0;
                        destreg = '0;
                    end   
                    `B_BGEZAL: begin
                        op = BGEZAL;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.branch_type = T_BGEZ;
                        ctl.is_link = 'b1;
                        srcrega = rs;
                        srcregb = '0;
                        destreg = 5'b11111;
                    end 
                    `B_BLTZAL: begin
                        op = BLTZAL;
                        ctl.branch = 1'b1;
                        ctl.branch1 = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.branch_type = T_BLTZ;
                        ctl.is_link = 'b1;
                        srcrega = rs;
                        srcregb = '0;
                        destreg = 5'b11111;
                    end 
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                        srcrega = '0;
                        srcregb = '0;
                        destreg = '0;
                    end
                endcase
            end
            `OP_BGTZ: begin
                op = BGTZ;
                ctl.branch = 1'b1;
                ctl.branch1 = 1'b1;
                ctl.branch_type = T_BGTZ;
                srcrega = rs;
                srcregb = '0;
                destreg = '0;
            end  
            `OP_BLEZ: begin
                op = BLEZ;
                ctl.branch = 1'b1;
                ctl.branch1 = 1'b1;
                ctl.branch_type = T_BLEZ;
                srcrega = rs;
                srcregb = '0;
                destreg = '0;
            end              
            `OP_J: begin
                op = J;
                ctl.jump = 1'b1;
                srcrega = '0;
                srcregb = '0;
                destreg = '0;
            end     
            `OP_JAL: begin
                op = JAL;
                ctl.jump = 1'b1;
                ctl.regwrite = 1'b1;
                ctl.is_link = 'b1;
                srcrega = '0;
                srcregb = '0;
                destreg = 5'b11111;
            end   
            `OP_LB: begin
                op = LB;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end    
            `OP_LBU: begin
                op = LBU;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end   
            `OP_LH: begin
                op = LH;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end    
            `OP_LHU: begin
                op = LHU;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end   
            `OP_LW: begin
                op = LW;
                ctl.regwrite = 1'b1;
                ctl.memtoreg = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = '0;
                destreg = rt;
            end    
            `OP_SB: begin
                op = SB;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = rt;
                destreg = '0;
            end    
            `OP_SH: begin
                op = SH;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = rt;
                destreg = '0;
            end    
            `OP_SW: begin
                op = SW;
                ctl.memwrite = 1'b1;
                ctl.alusrc = IMM;
                srcrega = rs;
                srcregb = rt;
                destreg = '0;
            end    
            `OP_ERET: begin
                case (instr[25:21])
                    `C_ERET:begin
                        op = ERET;
                        ctl.is_eret = 1'b1;
                        srcrega = '0;
                        srcregb = '0;
                        destreg = '0;        
                    end 
                    `C_MFC0:begin
                        op = MFC0;
                        ctl.alufunc = ALU_PASSA;
                        ctl.regwrite = 1'b1;
                        ctl.cp0toreg = 1'b1;
                        srcrega = '0;
                        srcregb = '0;
                        destreg = rt;
                    end 
                    `C_MTC0:begin
                        op = MTC0;
                        ctl.cp0write = 1'b1;
                        ctl.alufunc = ALU_PASSB;
                        srcrega = '0;
                        srcregb = rt;
                        destreg = '0;
                    end 
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                        srcrega = '0;
                        srcregb = '0;
                        destreg = '0;
                    end
                endcase
            end
            `OP_RT: begin
                case (func)
                    `F_ADD: begin
                        op = ADD;
                        ctl.alufunc = ALU_ADD;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end    
                    `F_ADDU: begin
                        op = ADDU;
                        ctl.alufunc = ALU_ADDU;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end   
                    `F_SUB: begin
                        op = SUB;
                        ctl.alufunc = ALU_SUB;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end    
                    `F_SUBU: begin
                        op = SUBU;
                        ctl.alufunc = ALU_SUBU;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end   
                    `F_SLT: begin
                        op = SLT;
                        ctl.alufunc = ALU_SLT;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end    
                    `F_SLTU: begin
                        op = SLTU;
                        ctl.alufunc = ALU_SLTU;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end   
                    `F_DIV: begin
                        op = DIV;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = '0;
                    end    
                    `F_DIVU: begin
                        op = DIVU;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = '0;
                    end   
                    `F_MULT: begin
                        op = MULT;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = '0;
                    end   
					`F_MULTU:begin
                        op = MULTU;
                        ctl.hiwrite = 1'b1;
                        ctl.lowrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = '0;
                    end	
					`F_AND:begin
                        op = AND;
                        ctl.alufunc = ALU_AND;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_NOR:begin
                        op = NOR;
                        ctl.alufunc = ALU_NOR;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_OR:begin
                        op = OR;
                        ctl.alufunc = ALU_OR;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_XOR:begin
                        op = XOR;
                        ctl.alufunc = ALU_XOR;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_SLLV:begin
                        op = SLLV;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end	
					`F_SLL:begin
                        op = SLL;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        ctl.shamt_valid = 1'b1;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_SRAV:begin
                        op = SRAV;
                        ctl.alufunc = ALU_SRA;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                        
                    end	
					`F_SRA:begin
                        op = SRA;
                        ctl.alufunc = ALU_SRA;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        ctl.shamt_valid = 1'b1;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_SRLV:begin
                        op = SRLV;
                        ctl.alufunc = ALU_SRL;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;

                    end	
					`F_SRL:begin
                        op = SRL;
                        ctl.alufunc = ALU_SRL;
                        ctl.regwrite = 1'b1;
                        ctl.alusrc = REGB;
                        ctl.shamt_valid = 1'b1;
                        srcrega = rs;
                        srcregb = rt;
                        destreg = rd;
                    end		
					`F_JR:begin
                        op = JR;
                        ctl.jump = 1'b1;
                        ctl.jr = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                        srcrega = rs;
                        srcregb = 'b0;
                        destreg = 'b0;
                    end		
					`F_JALR:begin
                        op = JALR;
                        ctl.jump = 1'b1;
                        ctl.jr = 1'b1;
                        ctl.regwrite = 1'b1;
                        ctl.is_link = 'b1;
                        ctl.alufunc = ALU_PASSA;
                        srcrega = rs;
                        srcregb = 'b0;
                        destreg = 5'b11111;
                    end	
					`F_MFHI:begin
                        op = MFHI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                        ctl.hitoreg = 1'b1;
                        srcrega = 'b0;
                        srcregb = 'b0;
                        destreg = rd;
                    end	
					`F_MFLO:begin
                        op = MFLO;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_PASSB;
                        ctl.lotoreg = 1'b1;
                        srcrega = 'b0;
                        srcregb = 'b0;
                        destreg = rd;
                    end	
					`F_MTHI:begin
                        op = MTHI;
                        ctl.hiwrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                        srcrega = rs;
                        srcregb = 'b0;
                        destreg = 'b0;
                    end	
					`F_MTLO:begin
                        op = MTLO;
                        ctl.lowrite = 1'b1;
                        ctl.alufunc = ALU_PASSA;
                        srcrega = rs;
                        srcregb = 'b0;
                        destreg = 'b0;
                    end	
					`F_BREAK:begin
                        op = BREAK;
                        ctl.alufunc = ALU_PASSA;
                        ctl.is_bp = 1'b1;
                        srcrega = 'b0;
                        srcregb = 'b0;
                        destreg = 'b0;
                    end	
					`F_SYSCALL:begin
                        op = SYSCALL;
                        ctl.alufunc = ALU_PASSA;
                        ctl.is_sys = 1'b1;
                        srcrega = 'b0;
                        srcregb = 'b0;
                        destreg = 'b0;
                    end	
                    default: begin
                        exception_ri = 1'b1;
                        op = RESERVED;
                        ctl.alufunc = ALU_PASSA;
                        srcrega = 'b0;
                        srcregb = 'b0;
                        destreg = 'b0;
                    end
                endcase
            end
            default: begin
                exception_ri = 1'b1;
                op = RESERVED;
                ctl.alufunc = ALU_PASSA;
                srcrega = 'b0;
                srcregb = 'b0;
                destreg = 'b0;
            end
        endcase
	end
endmodule