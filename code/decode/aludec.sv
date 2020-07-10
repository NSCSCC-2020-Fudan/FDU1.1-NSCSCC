`include "mips.svh"
module aludec (
	input decoded_op_t op,
	output alufunc_t alufunc
);
    always_comb begin
        case (op)
			ADD:		alufunc = ALU_ADD;
			ADDU:		alufunc = ALU_ADDU;
			SUB:		alufunc = ALU_SUB;
			SUBU:		alufunc = ALU_SUBU;
			SLT:		alufunc = ALU_SLT;
			SLTU:		alufunc = ALU_SLTU;
			AND:		alufunc = ALU_AND;
			NOR:		alufunc = ALU_NOR;
			OR:			alufunc = ALU_OR;
			XOR:		alufunc = ALU_XOR;
			SLLV:		alufunc = ALU_SLL;
			SLL:		alufunc = ALU_SLL;
			SRAV:		alufunc = ALU_SRA;
			SRA:		alufunc = ALU_SRA;
			SRLV:		alufunc = ALU_SRL;
			SRL:		alufunc = ALU_SRL;
			LUI:		alufunc = ALU_SLL;
			default: 	alufunc = ALU_ADDU;
        endcase
    end
endmodule