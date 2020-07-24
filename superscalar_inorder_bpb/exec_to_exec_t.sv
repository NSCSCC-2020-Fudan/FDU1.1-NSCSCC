`include "mips.svh"

module exec_to_exec_t(
        input exec_data_t a,
        output exec_data_t b
    );
    assign b.instr = a.instr;
    assign b.pcplus4 = a.pcplus4;
    assign b.exception_instr = a.exception_instr;
    assign b.exception_ri = a.exception_ri;
    assign b.exception_of = a.exception_of;
    assign b.taken = a.taken;
    assign b.srca = a.srca;
    assign b.srcb = a.srcb;
    assign b.destreg = a.destreg;
    assign b.result = a.result;
    assign b.hiresult = a.hiresult;
    assign b.loresult = a.loresult;
    assign b.in_delay_slot = a.in_delay_slot;
    
endmodule
