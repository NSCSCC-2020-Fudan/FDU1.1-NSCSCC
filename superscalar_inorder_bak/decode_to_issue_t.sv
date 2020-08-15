`include "mips.svh"

module decode_to_issue_t(
        input decode_data_t in,
        input word_t hi, lo,
        input word_t reg_dataa, reg_datab,
        input logic reg_readya, reg_readyb,
        //input word_t cp0_data, 
        output issue_data_t out,
        input logic BJp,
        input logic is_link
    );
    
    assign out.valid = 1'b1;
    assign out.instr = in.instr;
    assign out.pcplus4 = in.pcplus4;
    assign out.pred = in.pred;
    assign out.exception_instr = in.exception_instr;
    assign out.exception_ri = in.exception_ri;
    assign out.cp0_addr = in.cp0_addr;
    // assign out.exception_of = 'b0;
    assign out.srca = (in.instr.ctl.hitoreg)           ? (hi)         : (
                      (in.instr.ctl.cp0toreg)          ? ('0)         : (
                      (is_link && in.srcrega == 5'd31) ? (in.pcplus4) : reg_dataa));

    assign out.srcb = (in.instr.ctl.lotoreg)           ? (lo)         : (
                      (is_link && in.srcregb == 5'd31) ? (in.pcplus4) : (reg_datab));
                      
    assign out.destreg = in.destreg;
    assign out.srcrega = in.srcrega;
    assign out.srcregb = in.srcregb;
    assign out.cp0_sel = in.cp0_sel;
    assign out.in_delay_slot = BJp;
    //assign out.cp0_status = cp0_statusI;
    //assign out.cp0_cause = cp0_causeI;
    //assign out.cp0_epc = cp0_epcI;
    assign out.srchi = hi;
    assign out.srclo = lo;
    assign out.jrtop = in.jrtop;
    
    assign out.state.readya = (reg_readya && ~in.instr.ctl.cp0toreg) | 
                              (is_link    && (in.srcrega == 5'd31));
    assign out.state.readyb = reg_readyb;
    assign out.state.ready = 1'b0;
    
    assign out.instr_tlb_invalid = in.instr_tlb_invalid;
    assign out.instr_tlb_refill = in.instr_tlb_refill;

endmodule