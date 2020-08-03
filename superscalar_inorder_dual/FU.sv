`include "mips.svh"

module FU(
        input logic clk, reset, flushE, first_cycpeE,
        input issue_data_t in,
        output exec_data_t out,
        output logic finish,
        input logic mul_timeok, div_timeok,
        //execute
        output word_t multsrca, multsrcb,
        output decoded_op_t mult_op,
        output logic multen,
        input word_t hi, lo, multok
        //mult
    );

    decoded_op_t op;
    assign op = in.instr.op;
    alufunc_t func;
    assign func = in.instr.ctl.alufunc;
    logic multype, divtype;
    assign multype = (op == MULT) || (op == MULTU);
    assign divtype = (op == DIV) || (op == DIVU);
    
    word_t alusrcaE, alusrcbE;
    assign alusrcaE = (in.instr.ctl.shamt_valid)    ? ({27'b0, in.instr.shamt}) : (in.srca);
    assign alusrcbE = (in.instr.ctl.alusrc == REGB) ? (in.srcb)                 : (in.instr.extended_imm);

    word_t result;
    logic exception_of, taken, multfinish;
    /*
    DIVU DIVU (alusrcaE, alusrcbE, op, divtype, hi_div, lo_div, div_finish);
    MULU MULU (alusrcaE, alusrcbE, op, multype, hi_mul, lo_mul, mul_finish);
    */
    //mult mult(clk, reset, flushE, alusrcaE, alusrcbE, op, hi, lo, multok);
    assign multsrca = alusrcaE;
    assign multsrcb = alusrcbE;
    assign mult_op = op;
    
    
    ALU ALU (alusrcaE, alusrcbE, func, result, exception_of);
    JUDGE JUDGE(alusrcaE, alusrcbE, in.instr.ctl.branch_type, taken);
    assign multfinish = (multok & ~first_cycpeE);
    assign finish = ((~divtype) && (~multype)) || multfinish; 
    //assign finish = 1'b1;

    assign out.taken = taken;
    assign out.instr = in.instr;
    assign out.pcplus4 = in.pcplus4;
    assign out.exception_instr = in.exception_instr;
    assign out.exception_ri = in.exception_ri;
    assign out.srca = in.srca;
    assign out.srcb = in.srcb;
    assign out.destreg = in.destreg;
    assign out.in_delay_slot = in.in_delay_slot;
    assign out.cp0_addr = in.cp0_addr;
    assign out.cp0_cause = in.cp0_cause;
    assign out.cp0_status = in.cp0_status;
    assign out.cp0_epc = in.cp0_epc;
    assign out.pred = in.pred;
    
    word_t pcplus8;
    adder adderpcplus8(in.pcplus4, 32'b0100, pcplus8);
    
    assign out.hiresult = (multype | divtype) ? (hi) : (result);//mul/div or HTHI 
    assign out.loresult = (multype | divtype) ? (lo) : (result);//mul/div or HTLO
    assign out.result = (in.instr.ctl.is_link)   ? (pcplus8) : (
                        (in.instr.ctl.mul_div_r) ? (lo)      : (result));
    assign out.exception_of = (multype | divtype) ? ('0) : (exception_of);

endmodule