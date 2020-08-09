`include "mips.svh"

module mem_to_reg(
        input exec_data_t in,
        input m_q_t mem,
        output exec_data_t out
    );
    
    assign out.valid = in.valid;
    assign out.instr = in.instr;
    assign out.pcplus4 = in.pcplus4;
    assign out.exception_instr = in.exception_instr;
    assign out.exception_ri = in.exception_ri;
    assign out.exception_of = in.exception_of; 
    assign out.taken = in.taken;
    assign out.srca = in.srca;
    assign out.srcb = in.srcb;
    assign out.destreg = in.destreg;
    assign out.srcrega = in.srcrega;
    assign out.srcregb = in.srcregb;
    assign out.result = (in.instr.ctl.memtoreg) ? (mem.rd) : (in.result);
    assign out.hiresult = in.hiresult;
    assign out.loresult = in.loresult;
    assign out.in_delay_slot = in.in_delay_slot;
    assign out.cp0_addr = in.cp0_addr;
    assign out.pred = in.pred;
    assign out.jrtop = in.jrtop;
    
    assign out.state = 3'b1;
    
endmodule
