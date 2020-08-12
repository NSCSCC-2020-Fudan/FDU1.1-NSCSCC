`include "mips.svh"

module delayexecute(
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        output creg_addr_t [3: 0] reg_addrC,
        input word_t [3: 0] reg_dataC,
        input word_t srchi, srclo,
        //output creg_addr_t [1: 0] cp0_addrC,
        input word_t [1: 0] cp0_dataC
    );
    
    logic [1: 0] FU_finish;
    exec_data_t [1: 0] FU_result;
    
    assign reg_addrC = {in[1].srcrega, in[1].srcregb, in[0].srcrega, in[0].srcregb};
    //assign cp0_addrC = {in[1].cp0_addr, in[0].cp0_addr};

    delayFU delayFU1(.in(in[1]), .out(FU_result[1]),
                     .reg_dataa(reg_dataC[3]), .reg_datab(reg_dataC[2]), 
                     .hi_data(srchi), .lo_data(srclo), 
                     .cp0_data(cp0_dataC[1]));
    delayFU delayFU0(.in(in[0]), .out(FU_result[0]),
                     .reg_dataa(reg_dataC[1]), .reg_datab(reg_dataC[0]), 
                     .hi_data(srchi), .lo_data(srclo), 
                     .cp0_data(cp0_dataC[0]));
    assign out[1] = FU_result[1];
    assign out[0] = FU_result[0];
    
    /*
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
    assign bypass.cp0_modify = {out[1].instr.ctl.cp0_modify, out[0].instr.ctl.cp0_modify};
    */
    
endmodule