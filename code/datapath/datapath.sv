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
    memory_DRAM memory_DRAM(.rd, .mread, .mwrite);
    memory_wreg_writeback memory_wreg_writeback();
    regfile_intf regfile_intf(.rfwrite);
    hilo_intf hilo_intf();
    cp0_intf cp0_intf();
    hazard_intf hazard_intf();
    exception_intf exception_intf();
    pcselect_intf pcselect_intf();

    Freg freg_(.ports(pcselect_freg_fetch.freg), 
               .clk, .reset);
    fetch fetch_(.in(pcselect_freg_fetch.fetch), 
                 .out(fetch_dreg_decode.fetch), 
                 .pcselect(pcselect_intf.fetch));
    pcselect pcselect_(.out(pcselect_freg_fetch.pcselect),
                       .in(pcselect_intf.pcselect));
    
    Dreg dreg_(.clk, .reset, 
               .ports(fetch_dreg_decode.dreg),
               .hazard(hazard_intf.dreg));
    decode decode_(.in(fetch_dreg_decode.decode),
                   .out(decode_ereg_exec.decode),
                   .regfile(regfile_intf.decode),
                   .hilo(hilo_intf.decode),
                   .cp0(cp0_intf.decode),
                   .hazard(hazard_intf.decode));
    
    Ereg ereg_(.clk, .reset, 
               .ports(decode_ereg_exec.ereg),
               .hazard(hazard_intf.ereg));
    execute execute_(.in(decode_ereg_exec.exec),
                     .out(exec_mreg_memory.exec));
    
    Mreg mreg_(.clk, .reset,
               .ports(exec_mreg_memory.mreg),
               .hazard(hazard_intf.mreg));
    memory memory_(.in(exec_mreg_memory.memory),
                   .out(memory_wreg_writeback.memory),
                   .());
    
    Wreg wreg_(.clk, .reset,
               .ports(memory_wreg_writeback.wreg),
               .hazard(hazard_intf.wreg));
    writeback writeback_(.pc(wb_pc));

    // regfile interacts with Decode, Writeback
    regfile regfile_();

    // hilo interacts with Decode, Writeback
    hilo hilo_();

    // cp0 interacts with memory, exception
    cp0 cp0_();

    // hazard interacts with Freg, Dreg, Ereg, Mreg, Wreg, Decode, Execute, Memory
    hazard hazard(hazard_intf.hazard);

    // exception interacts with cp0, pcselect, memory
    exception exception_(exception_intf.exception);
endmodule