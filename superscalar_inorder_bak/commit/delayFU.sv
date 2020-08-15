`include "mips.svh"

module delayFU(
        input exec_data_t in,
        output exec_data_t out,
        input word_t reg_dataa, reg_datab,
        input word_t hi_data, lo_data,
        input word_t cp0_data
    );

    decoded_op_t op;
    assign op = in.instr.op;
    alufunc_t func;
    assign func = in.instr.ctl.alufunc;
    
    word_t srca, srcb;
    assign srca = (in.state.readya)       ? (in.srca)  : (                  
                  (in.instr.ctl.hitoreg)  ? (hi_data)  : (
                  (in.instr.ctl.cp0toreg) ? (cp0_data) : (reg_dataa)));
    assign srcb = (in.state.readyb)      ? (in.srcb) : (
                  (in.instr.ctl.lotoreg) ? (lo_data) : (reg_datab));
    
    word_t alusrcaE, alusrcbE;
    assign alusrcaE = (in.instr.ctl.shamt_valid)    ? ({27'b0, in.instr.shamt}) : (srca);
    assign alusrcbE = (in.instr.ctl.alusrc == REGB) ? (srcb)                    : (in.instr.extended_imm);
    
    logic multen;
    logic exception_of;
    assign multen = in.instr.ctl.mul_div_r;
    
    /*
    DIVU DIVU (alusrcaE, alusrcbE, op, divtype, hi_div, lo_div, div_finish);
    MULU MULU (alusrcaE, alusrcbE, op, multype, hi_mul, lo_mul, mul_finish);
    */
    //mult mult(clk, reset, flushE, alusrcaE, alusrcbE, op, hi, lo, multok);
    word_t result_alu, result;
    assign result = (~in.state.ready) ? (result_alu) : (in.result);
    ALU ALU (alusrcaE, alusrcbE, func, result_alu, exception_of);
    
    assign out.taken = in.taken;
    //assign out.instr = in.instr;
    always_comb
        begin
            out.instr = in.instr;
            out.instr.ctl.regwrite = (in.instr.op == MOVZ) ? (alusrcbE == 0) : (
                                     (in.instr.op == MOVN) ? (alusrcbE != 0) : (in.instr.ctl.regwrite));  
        end
    assign out.valid = in.valid;        
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
    assign out.state = 3'b1;
    
    word_t pcplus8;
    adder adderpcplus8(in.pcplus4, 32'b0100, pcplus8);
    
    assign out.hiresult = (~in.state.ready) ? (result_alu) : (in.hiresult);//mul/div or HTHI 
    assign out.loresult = (~in.state.ready) ? (result_alu) : (in.loresult);//mul/div or HTHI
    assign out.result = result;
    assign out.exception_of = in.exception_of;
    assign out.instr_tlb_invalid = in.instr_tlb_invalid;
    assign out.instr_tlb_refill = in.instr_tlb_refill;

endmodule