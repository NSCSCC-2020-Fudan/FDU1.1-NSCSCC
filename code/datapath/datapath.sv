`include "mips.svh"

module datapath (
    
);
    word_t pc;
    word_t instr;

    // interfaces
    pcs_freg_fetch pcs_freg_fetch(.pc);
    fetch_dreg_decode fetch_dreg_decode(.instr_new(instr));
    decode_ereg_exec decode_ereg_exec();
    exec_mreg_memory exec_mreg_memory();
    memory_DRAM memory_DRAM();
    memory_wreg_writeback memory_wreg_writeback();
    regfile_intf regfile_intf();
    hilo_intf hilo_intf();
    cp0_intf cp0_intf();
    hazard_intf hazard_intf();
    exception_intf exception_intf();

    Freg freg_(.ports(pcs_freg_fetch.freg), .clk(clk), .reset(reset));
    fetch fetch_();
    pcselect pcselect_();
    
    Dreg dreg_();
    decode decode_();
    
    Ereg ereg_();
    execute execute_();
    
    Mreg mreg_();
    memory memory_();
    
    Wreg wreg_();
    writeback writeback_();

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