`include "mips.svh"

module bpbdecode(
		input word_t pc, pcplus4, instr,
		input bpb_result_t in,
		output bpb_result_t out
    );
    
    op_t op;
    assign op = instr[31:26];
    logic j_pc, b_pc;
    always_comb
        begin
            j_pc = 1'b0;
            b_pc = 1'b0;
            case (op)
                `OP_J: j_pc = 1'b1;     
                `OP_JAL: j_pc = 1'b1;
                `OP_BEQ: b_pc = 1'b1;  
                `OP_BNE: b_pc = 1'b1;
                `OP_BGEZ: b_pc = 1'b1;
                `OP_BGTZ: b_pc = 1'b1;
                `OP_BLEZ: b_pc = 1'b1;
                default: b_pc = 1'b0;
            endcase
        end
    
    assign out.taken = in.taken & (j_pc | b_pc);        
    
    word_t ext_imm, pcbranch, pcjump, destpc;
	extend ext_pb(instr[15: 0], 1'b0, ext_imm);
	assign pcjump = {pcplus4[31: 28], instr[25:0], 2'b00};
	assign pcbranch = pcplus4 + {ext_imm[29:0], 2'b00};
    assign destpc = (j_pc) ? (pcjump)   : ( 
                    (b_pc) ? (pcbranch) : ('0));
                    
    assign out.destpc = destpc;                    
    
endmodule
