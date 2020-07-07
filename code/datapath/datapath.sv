`include "mips.svh"

module datapath (
    
// );
//     word_t pc;
//     Freg_intf freg_intf(pc);

//     word_t instr;
//     Dreg_intf dreg_intf(instr);

//     word_t pcexception;
//     logic exception;
    
//     Pcselect_intf(pcexception, exception);

    Freg freg_();
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

    // cp0 interacts with memory, pcselect, exception
    cp0 cp0_();

    // hazard interacts with Freg, Dreg, Ereg, Mreg, Wreg, Decode, Execute, Memory
    hazard hazard();

    // exception interacts with cp0, 
    exception exception_();
endmodule