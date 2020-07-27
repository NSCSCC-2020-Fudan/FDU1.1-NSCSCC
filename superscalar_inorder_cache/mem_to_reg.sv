`include "mips.svh"

module mem_to_reg(
        input exec_data_t in,
        input m_q_t mem,
        output exec_data_t out
    );
    
    assign out.instr = in.instr;
    assign out.pcplus4 = in.pcplus4;
    assign out.exception_instr = in.exception_instr;
    assign out.exception_ri = in.exception_ri;
    assign out.exception_of = in.exception_of; 
    assign out.taken = in.taken;
    assign out.srca = in.srca;
    assign out.srcb = in.srcb;
    assign out.destreg = in.destreg;
    assign out.result = (in.instr.ctl.memtoreg) ? (mem.rd) : (in.result);
    assign out.hiresult = in.hiresult;
    assign out.loresult = in.loresult;
    assign out.in_delay_slot = in.in_delay_slot;
    assign out.cp0_status = in.cp0_status;
    assign out.cp0_cause = in.cp0_cause;
    assign out.cp0_addr = in.cp0_addr;
    assign out.cp0_epc = in.cp0_epc;
    assign out.pred = in.pred;
    
endmodule
