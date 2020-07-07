`include "mips.svh"
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