`include "mips.svh"

module bpbdecode(
		input word_t pc, pcplus4, instr,
		input bpb_result_t in,
		output bpb_result_t out,
		output logic jr_push, jr_pop,
		input word_t jr_destpc,
		input logic [`JR_ENTRY_WIDTH - 1: 0] jr_topF_in,
		output logic [`JR_ENTRY_WIDTH - 1: 0] jr_topF_out
    );
    
    op_t op;
    assign op = instr[31:26];
    func_t func;
    assign func = instr[5:0];
    logic j_pc, b_pc, jr_pc;
    always_comb
        begin
            j_pc = 1'b0;
            b_pc = 1'b0;
            jr_pc = 1'b0;
            jr_push = 1'b0;
            jr_pop = 1'b0;
            case (op)
                `OP_J: j_pc = 1'b1;     
                `OP_JAL: begin j_pc = 1'b1; jr_push = 1'b1; end
                `OP_BEQ: b_pc = 1'b1;  
                `OP_BNE: b_pc = 1'b1;
                `OP_BGEZ: 
                    begin
                        b_pc = 1'b1;
                        jr_push = (instr[20: 16] == `B_BGEZAL || instr[20: 16] == `B_BLTZAL);
                    end
                `OP_BGTZ: b_pc = 1'b1;
                `OP_BLEZ: b_pc = 1'b1;
                `OP_RT:
                    begin
                        jr_pc = (instr[5: 0] == `F_JR || instr[5: 0] == `F_JALR);
                        jr_pop = (instr[5: 0] == `F_JR || instr[5: 0] == `F_JALR) && (instr[25: 21] == 5'b11111);
                        jr_push = (instr[5: 0] == `F_JALR);
                    end
                default: b_pc = 1'b0;
            endcase
        end
    
    assign out.taken = (in.taken & b_pc) | j_pc | jr_pc;        
    
    word_t ext_imm, pcbranch, pcjump, destpc;
	extend ext_pb(instr[15: 0], 1'b0, ext_imm);
	assign pcjump = {pcplus4[31: 28], instr[25:0], 2'b00};
	assign pcbranch = pcplus4 + {ext_imm[29:0], 2'b00};
    assign destpc = (j_pc)  ? (pcjump)    : ( 
                    (b_pc)  ? (pcbranch)  : (
                    (jr_pc) ? (jr_destpc) : ('0)));
                    
    assign out.destpc = destpc;   
    
    logic [`JR_ENTRY_WIDTH - 1: 0] jr_top_plus, jr_top_minus;
    assign jr_top_plus = jr_topF_in + 2'b01;
    assign jr_top_minus = jr_topF_in - 2'b01;
    assign jr_topF_out = (~(jr_push ^ jr_pop)) ? (jr_topF_in)   : (
                         (jr_push)             ? (jr_top_plus)  : (
                         (jr_pop)              ? (jr_top_minus) : ('0)));                 
    
endmodule
