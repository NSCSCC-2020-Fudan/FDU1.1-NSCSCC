`include "mips.svh"

module retire(
        input exec_data_t [1: 0] in,
        output rf_w_t [1: 0] rfw,
        output word_t [1: 0] rt_pc, 
        output hilo_w_t hlw,
        //output rf_w_t [1: 0] cp0w,
        //register
        output bypass_upd_t bypass
    );

    assign bypass.destreg = {in[1].destreg, in[0].destreg};
    assign bypass.result = {in[1].result, in[0].result};
    assign bypass.hiwrite = {in[1].instr.ctl.hiwrite, in[0].instr.ctl.hiwrite};
    assign bypass.lowrite = {in[1].instr.ctl.lowrite, in[0].instr.ctl.lowrite};
    assign bypass.hidata = {in[1].hiresult, in[0].hiresult};
    assign bypass.lodata = {in[1].loresult, in[0].loresult};
    //assign bypass.memtoreg = {in[1].instr.ctl.memtoreg, in[0].instr.ctl.memtoreg};
    assign bypass.wen = {in[1].instr.ctl.regwrite, in[0].instr.ctl.regwrite};
    assign bypass.ready = {in[1].state.ready, in[0].state.ready};
    assign bypass.cp0_modify = {in[1].instr.ctl.cp0_modify, in[0].instr.ctl.cp0_modify};
    // signalretire signalretire [1: 0] (in[1], rfout, hiloout, cp0out);
    
    assign rfw[1].addr = in[1].destreg;
    assign rfw[1].wd = in[1].result;
    assign rfw[1].wen = in[1].instr.ctl.regwrite;
    assign rfw[0].addr = in[0].destreg;
    assign rfw[0].wd = in[0].result;
    assign rfw[0].wen = in[0].instr.ctl.regwrite;
    
    assign hlw.wen_h = in[1].instr.ctl.hiwrite | in[0].instr.ctl.hiwrite; 
    assign hlw.wen_l = in[1].instr.ctl.lowrite | in[0].instr.ctl.lowrite;
    assign hlw.wd_h = (in[0].instr.ctl.hiwrite) ? (in[0].hiresult) : (in[1].hiresult); 
    assign hlw.wd_l = (in[0].instr.ctl.lowrite) ? (in[0].loresult) : (in[1].loresult);
    
    /*
    assign cp0w[1].addr = in[1].cp0_addr;
    assign cp0w[1].wd = in[1].result;
    assign cp0w[1].wen = in[1].instr.ctl.cp0write;
    assign cp0w[0].addr = in[0].cp0_addr;
    assign cp0w[0].wd = in[0].result;
    assign cp0w[0].wen = in[0].instr.ctl.cp0write;
    */
    
    assign rt_pc[1] = in[1].pcplus4 - 32'd4;
    assign rt_pc[0] = in[0].pcplus4 - 32'd4;
endmodule