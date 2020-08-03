`include "mips.svh"

module execute(
        input logic clk, reset, first_cycpeE,
        input issue_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        //pipeline
        output logic finishE,
        input logic flushE, stallE, 
        //control
        output bypass_upd_t bypass,  
        //bypass
        input logic mul_timeok, div_timeok
    );
    
    logic [1: 0] FU_finish;
    exec_data_t [1: 0] FU_result;
    
    logic multok, multen0, multen1;
    word_t multsrca1, multsrcb1, multsrca0, multsrcb0, hi, lo;
    decoded_op_t mult_op, mult_op1, mult_op0;
    FU FU1 (clk, reset, flushE, first_cycpeE, 
    		in[1], FU_result[1], FU_finish[1], 
    		mul_timeok, div_timeok,
    		multsrca1, multsrcb1, mult_op1, multen1,
    		hi, lo, multok);
    FU FU0 (clk, reset, flushE, first_cycpeE, 
    		in[0], FU_result[0], FU_finish[0], 
    		mul_timeok, div_timeok,
    		multsrca0, multsrcb0, mult_op0, multen0,
    		hi, lo, multok);
    word_t multsrca, multsrcb;
    assign multsrca = (multen1) ? (multsrca1) : (multsrca0);
    assign multsrcb = (multen1) ? (multsrcb1) : (multsrcb0);
    assign mult_op = (multen1) ? (mult_op1) : (mult_op0);
    mult mult(clk, reset, flushE, multsrca, multsrcb, mult_op, hi, lo, multok);
    
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