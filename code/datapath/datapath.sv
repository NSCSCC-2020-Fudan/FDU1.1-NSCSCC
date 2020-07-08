`include "mips.svh"

module datapath (
    input logic clk, reset,
    input logic[5:0] ext_int,
    
    output word_t pc,
    input word_t instr,

    output m_r_t mread,
    output m_w_t mwrite,
    output rf_w_t rfwrite,
    input word_t rd,
    output word_t wb_pc
);
    // interfaces
    pcselect_freg_fetch pcselect_freg_fetch(.pc);
    fetch_dreg_decode fetch_dreg_decode(.instr);
    decode_ereg_exec decode_ereg_exec();
    exec_mreg_memory exec_mreg_memory();
    memory_dram memory_dram(.rd, .mread, .mwrite);
    memory_wreg_writeback memory_wreg_writeback();
    regfile_intf regfile_intf(.rfwrite);
    hilo_intf hilo_intf();
    cp0_intf cp0_intf();
    hazard_intf hazard_intf();
    exception_intf exception_intf();
    pcselect_intf pcselect_intf ();

    Freg_ freg_(.ports(pcselect_freg_fetch.freg), 
               .clk, .reset, .hazard(hazard_intf.freg));
    fetch_ fetch_(.in(pcselect_freg_fetch.fetch), 
                 .out(fetch_dreg_decode.fetch), 
                 .pcselect(pcselect_intf.fetch));
    pcselect_ pcselect_(.out(pcselect_freg_fetch.pcselect),
                       .in(pcselect_intf.pcselect));
    
    Dreg_ dreg_(.clk, .reset, 
               .ports(fetch_dreg_decode.dreg),
               .hazard(hazard_intf.dreg));
    decode_ decode_(.in(fetch_dreg_decode.decode),
                   .out(decode_ereg_exec.decode),
                   .regfile(regfile_intf.decode),
                   .hilo(hilo_intf.decode),
                   .cp0(cp0_intf.decode),
                   .hazard(hazard_intf.decode),
                   .pcselect(pcselect_intf.decode));
    
    Ereg_ ereg_(.clk, .reset, 
               .ports(decode_ereg_exec.ereg),
               .hazard(hazard_intf.ereg));
    execute_ execute_(.in(decode_ereg_exec.exec),
                     .out(exec_mreg_memory.exec),
                     .hazard(hazard_intf.exec));
    
    Mreg_ mreg_(.clk, .reset,
               .ports(exec_mreg_memory.mreg),
               .hazard(hazard_intf.mreg));
    memory_ memory_(.in(exec_mreg_memory.memory),
                   .out(memory_wreg_writeback.memory),
                   .hazard(hazard_intf.memory),
                   .exception(exception_intf.memory),
                   .dram(memory_dram.memory));
    
    Wreg_ wreg_(.clk, .reset,
               .ports(memory_wreg_writeback.wreg),
               .hazard(hazard_intf.wreg));
    writeback_ writeback_(.pc(wb_pc),
                         .in(memory_wreg_writeback.writeback),
                         .regfile(regfile_intf.writeback),
                         .hilo(hilo_intf.writeback),
                         .cp0(cp0_intf.writeback),
                         .hazard(hazard_intf.writeback));

    // regfile interacts with Decode, Writeback
    regfile_ regfile_(.ports(regfile_intf.regfile), .clk, .reset);

    // hilo interacts with Decode, Writeback
    hilo_ hilo_(.ports(hilo_intf.hilo),.clk, .reset);

    // cp0 interacts with memory, exception
    // cp0_ cp0_(.ports(cp0_intf.cp0),
    //          .exception(exception_intf.exception));

    // hazard interacts with Freg, Dreg, Ereg, Mreg, Wreg, Decode, Execute, Memory
    hazard_ hazard(hazard_intf.hazard);

    // exception interacts with cp0, pcselect, memory
    // exception_ exception_(exception_intf.excep);
endmodule