`include "mips.svh"

module decode_to_issue_t(
        input decode_data_t in,
        input word_t hi, lo,
        input word_t reg_dataa, reg_datab,
        input word_t cp0_data, 
        input cp0_status_t cp0_statusI, 
        input cp0_cause_t cp0_causeI,
        output issue_data_t out,
        input logic BJp
    );
    
    assign out.instr = in.instr;
    assign out.pcplus4 = in.pcplus4;
    assign out.exception_instr = in.exception_instr;
    assign out.exception_ri = in.exception_ri;
    assign out.cp0_addr = in.cp0_addr;
    // assign out.exception_of = 'b0;
    assign out.srca = (in.instr.ctl.hitoreg) ? (hi) : (
                      (in.instr.ctl.cp0toreg) ? (cp0_data) :(reg_dataa));
    assign out.srcb = (in.instr.ctl.lotoreg) ? (lo) : (reg_datab);
    assign out.destreg = in.destreg;
    assign out.in_delay_slot = BJp;
    assign out.cp0_status = cp0_statusI;
    assign out.cp0_cause = cp0_causeI;

endmodule