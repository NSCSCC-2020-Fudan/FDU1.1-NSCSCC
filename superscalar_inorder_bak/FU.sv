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
        input word_t hi, lo,
        input logic multok
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
    
    logic multmask;
    assign multsrca = alusrcaE;
    assign multsrcb = alusrcbE;
    assign mult_op = (multype || divtype)                                         ? (op)    : ( 
                     ((in.instr.op == MADD || in.instr.op == MSUB) & ~multmask)   ? (MULT)  : (
                     ((in.instr.op == MADDU || in.instr.op == MSUBU) & ~multmask) ? (MULTU) : (ADDU)));
    assign multen = in.instr.ctl.mul_div_r;

    word_t result_cl, result_alu, result;
    logic exception_of, taken, multfinish;
    /*
    DIVU DIVU (alusrcaE, alusrcbE, op, divtype, hi_div, lo_div, div_finish);
    MULU MULU (alusrcaE, alusrcbE, op, multype, hi_mul, lo_mul, mul_finish);
    */
    //mult mult(clk, reset, flushE, alusrcaE, alusrcbE, op, hi, lo, multok);
    logic cl;
    assign cl = (in.instr.op == CLO) | (in.instr.op == CLZ);
    ALUCL ALUCL((in.instr.op == CLZ) ? (alusrcaE) : (~alusrcaE), result_cl);
    ALU ALU (alusrcaE, alusrcbE, func, result_alu, exception_of);
    JUDGE JUDGE(alusrcaE, alusrcbE, in.instr.ctl.branch_type, taken);
    assign result = cl ? (result_cl) : (result_alu);
    
    logic maluexception_of, malufinish, maluok;
    word_t hi_mult, lo_mult;
    assign multfinish = (multok & ~first_cycpeE);
    assign malufinish = (maluok & ~first_cycpeE);
    assign finish = (~in.instr.ctl.mul_div_r)            || 
                    ((multype || divtype) && multfinish) || 
                    (~(multype || divtype) && malufinish);
    MULALU MULALU(clk, reset, flushE,
                  in.instr.ctl.mulfunc, 
                  in.srchi, in.srclo,
                  hi, lo, 
                  hi_mult, lo_mult, 
                  multen, multfinish & ~multmask, 
                  maluok, maluexception_of,
                  multmask); 
    //assign finish = 1'b1;

    assign out.valid = in.valid;
    assign out.taken = taken;
    //assign out.instr = in.instr;
    always_comb
        begin
            out.instr = in.instr;
            out.instr.ctl.regwrite = (in.instr.op == MOVZ) ? (alusrcbE == 32'b0) : (
                                     (in.instr.op == MOVN) ? (alusrcbE != 32'b0) : (in.instr.ctl.regwrite));  
        end
    assign out.pcplus4 = in.pcplus4;
    assign out.exception_instr = in.exception_instr;
    assign out.exception_ri = in.exception_ri;
    assign out.srca = in.srca;
    assign out.srcb = in.srcb;
    assign out.destreg = in.destreg;
    assign out.srcrega = in.srcrega;
    assign out.srcregb = in.srcregb;
    assign out.cp0_sel = in.cp0_sel;
    assign out.in_delay_slot = in.in_delay_slot;
    assign out.cp0_addr = in.cp0_addr;
    assign out.pred = in.pred;
    assign out.jrtop = in.jrtop;
    
    assign out.state.readya = in.state.readya;
    assign out.state.readyb = in.state.readyb;
    assign out.state.ready = in.state.readya & in.state.readyb & (~(in.instr.ctl.memtoreg || in.instr.ctl.is_sc));
    
    assign out.instr_tlb_invalid = in.instr_tlb_invalid;   
    assign out.instr_tlb_refill = in.instr_tlb_refill;                          
    
    word_t pcplus8;
    adder adderpcplus8(in.pcplus4, 32'b0100, pcplus8);
    
    assign out.hiresult = (~multen)            ? (result) : (
                          (multype || divtype) ? (hi)     : (hi_mult));//mul/div or HTHI 
    assign out.loresult = (~multen)            ? (result) : (
                          (multype || divtype) ? (lo)     : (lo_mult));//mul/div or HTHI
    assign out.result = (in.instr.ctl.is_link)    ? (pcplus8) : (
                        (~in.instr.ctl.mul_div_r) ? (result)  : (
                        (multype || divtype)      ? (lo)      : (lo_mult)));
    assign out.exception_of = (multype | divtype | cl) ? ('0)           : (
                              (~multen)                ? (exception_of) : (maluexception_of));

endmodule