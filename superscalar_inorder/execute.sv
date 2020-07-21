`include "mips.svh"

module execute(
        input logic clk, reset,
        input issue_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        //pipeline
        output logic finishE,
        input logic flushE, stallE, 
        //control
        output bypass_upd_t bypass  
        //bypass
    );
    
    logic [1: 0] FU_finish;
    exec_data_t [1: 0] FU_result;
    FU FU [1: 0] (in, FU_result, FU_finish);
    
    logic finish;
    assign finish = FU_finish[1] && FU_finish[0];
    assign finishE = finish;
    
    assign out[1] = FU_result[1];
    assign out[0] = FU_result[0];
     
    assign bypass.destreg = {out[1].destreg, out[0].destreg};
    assign bypass.result = {out[1].result, out[0].result};
    assign bypass.hiwrite = {out[1].instr.ctl.hiwrite, out[0].instr.ctl.hiwrite};
    assign bypass.lowrite = {out[1].instr.ctl.lowrite, out[0].instr.ctl.lowrite};
    assign bypass.hidata = {out[1].hiresult, out[0].hiresult};
    assign bypass.lodata = {out[1].loresult, out[0].loresult};
    assign bypass.memtoreg = {out[1].instr.ctl.memtoreg, out[0].instr.ctl.memtoreg};
    assign bypass.cp0_addr = {out[1].cp0_addr, out[0].cp0_addr};
    assign bypass.wen = {out[1].instr.ctl.regwrite, out[0].instr.ctl.regwrite};
    assign bypass.cp0_wen = {out[1].instr.ctl.cp0write, out[0].instr.ctl.cp0write};
    
endmodule