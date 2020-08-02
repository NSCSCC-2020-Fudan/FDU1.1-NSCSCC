`include "mips.svh"

module commit(
        input logic clk, reset,
        (*mark_debug = "true"*) input exec_data_t [1: 0] in,
        (*mark_debug = "true"*) output exec_data_t [1: 0] out,
        //pipeline
        input logic first_cycleC, 
        output logic finishC, pc_mC,
        //control
        output logic dmem_wt,
        output word_t dmem_addr, dmem_wd, 
        input word_t dmem_rd,
        output logic dmem_en,
        output logic [1: 0] dmem_size,     
        input logic dmem_dataOK,
        //dmem
        output pc_data_t fetch,
        //fetch new pc
        output bypass_upd_t bypass,
        //data forward
        input logic [5: 0] ext_int,
        input logic timer_interrupt,
        output logic exception_valid,
        output exception_t exception_data,
        output logic is_eret,
        //cp0
        output word_t pc_commitC,
        output logic predict_wen,
        output bpb_result_t destpc_commitC
        //branch predict
    );
    
    exec_data_t [1: 0] _out;
    logic [1: 0] _exception_valid;
    word_t [1: 0] _pcexception;
    exception_t [1: 0] _exception_data;
    word_t pcexception;
    exception_checker exception_checker1 (reset, 1'b0,
                                          in[1],
                                          ext_int, timer_interrupt,
                                          _exception_valid[1], _pcexception[1], _exception_data[1],
                                          _out[1]);
    exception_checker exception_checker0 (reset, 1'b0,//(_exception_valid[1]) | (in[1].instr.op == ERET),
                                          in[0],
                                          ext_int, timer_interrupt,
                                          _exception_valid[0], _pcexception[0], _exception_data[0],
                                          _out[0]);
    assign exception_valid = _exception_valid[1] | _exception_valid[0];
    assign exception_data = (_exception_valid[1]) ? (_exception_data[1]) : (_exception_data[0]);    
    assign pcexception = (_exception_valid[1]) ? (_pcexception[1]) : (_pcexception[0]);
 	
 	logic mask;
 	assign mask = (_exception_valid[1]) | (in[1].instr.op == ERET);                                              
                                          
    m_q_t mem, __mem;
    m_q_t [1: 0] _mem;                                      
    writedata_format writedata_format1 (_out[1], _mem[1]);
    writedata_format writedata_format0 (_out[0], _mem[0]);                                                                                    
                    
    decoded_op_t __op;
    control_t [1: 0] ctl;
    assign ctl[1] = _out[1].instr.ctl;
    assign ctl[0] = _out[0].instr.ctl;
    assign __mem = (ctl[1].memtoreg | ctl[1].memwrite) ? (_mem[1]) : (_mem[0]);
    assign __op = (ctl[1].memtoreg | ctl[1].memwrite) ? (_out[1].instr.op) : (_out[0].instr.op);
    
    assign mem.wt = (in[1].instr.ctl.memwrite | in[0].instr.ctl.memwrite);
    assign mem.size = __mem.size;
    assign mem.addr = (in[1].instr.ctl.memtoreg | in[1].instr.ctl.memwrite) ? (in[1].result) : (in[0].result);
    assign mem.en = __mem.en;
    assign mem.wd = __mem.wd;
    
    assign dmem_wt = mem.wt;
    assign dmem_addr = mem.addr;
    assign dmem_wd = mem.wd;
    assign dmem_en = mem.en;
    assign dmem_size = mem.size;
    /*
    logic sbuffer_of, finishS;
    sbuffer sbuffer(.clk, .reset, 
                    .in(__mem), .out(mem),
                    .sbuffer_of, .finishS, .__op,
                    .dmem_wt,
                    .dmem_addr, .dmem_wd, 
                    .dmem_rd,
                    .dmem_en,
                    .dmem_size,     
                    .dataOK(dmem_dataOK));
    assign finishC = finishS;                    
    */
    readdata_format readdata_format (dmem_rd, mem.rd, mem.addr[1: 0], __op); 
    //assign mem.rd = dmem_rd;
    
    assign finishC = ((first_cycleC) ? (~mem.en) : ((~mem.en) | (dmem_dataOK)));
    assign pc_mC = fetch.jump | fetch.jr | fetch.branch;
    
    exec_data_t [1: 0] __out;
    mem_to_reg mem_to_reg1(_out[1], mem, __out[1]);
    mem_to_reg mem_to_reg0(_out[0], mem, __out[0]);
    assign out[1] = __out[1];
    assign out[0] = __out[0];
    //assign out = _out;
    

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
    // to bypass net
    
    assign fetch.exception_valid = exception_valid;
    assign fetch.is_eret = (out[1].instr.op == ERET) | (out[0].instr.op == ERET); 
    assign fetch.pcexception = pcexception; 
    assign fetch.epc = (out[1].instr.op == ERET) ? (out[1].cp0_epc) : (out[0].cp0_epc);
    assign fetch.branch = (out[1].instr.ctl.branch) & (out[1].taken != out[1].pred.taken);
    assign fetch.jump = (out[1].instr.ctl.jump) & (~out[1].pred.taken);  
    assign fetch.jr = out[1].instr.ctl.jr;
    assign fetch.pcbranch = (out[1].pred.taken) ? (out[0].pcplus4) : (out[1].instr.pcbranch);
    assign fetch.pcjr = out[1].srca;
    assign fetch.pcjump = out[1].instr.pcjump;
    // to fetch select pc
    
    assign is_eret = (_out[1].instr.op == ERET) | (_out[0].instr.op == ERET);
    
    logic judge;
    assign judge = (in[1].instr.ctl.branch | in[1].instr.ctl.jump) & (~fetch.jump & ~fetch.branch);
      
    assign pc_commitC = in[1].pcplus4 - 'd4;
    assign predict_wen = in[1].instr.ctl.branch || ((in[1].instr.ctl.jump) && (~in[1].instr.ctl.jr));
    assign destpc_commitC = {in[1].taken || (in[1].instr.ctl.jump & ~in[1].instr.ctl.jr), 
                             (in[1].instr.ctl.jump) ? (in[1].instr.pcjump) : (in[1].instr.pcbranch)};       
endmodule