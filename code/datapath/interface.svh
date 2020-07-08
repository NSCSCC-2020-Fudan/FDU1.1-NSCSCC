`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

`include "mips.svh"

interface pcselect_freg_fetch(output word_t pc);
    word_t pc_new;
    modport pcselect(output pc_new);
    modport freg(input pc_new, output pc);
    modport fetch(input pc);
endinterface

interface fetch_dreg_decode(input word_t instr);
    fetch_data_t dataF_new, dataF;
    modport fetch(input instr, output dataF_new);
    modport dreg(input dataF_new, output dataF);
    modport decode(input dataF);
endinterface

interface decode_ereg_exec();
    decode_data_t dataD_new, dataD;
    modport decode(output dataD_new);
    modport ereg(input dataD_new, output dataD);
    modport exec(input dataD);
endinterface

interface exec_mreg_memory();
    exec_data_t dataE_new, dataE;
    modport exec(output dataE_new);
    modport mreg(input dataE_new, output dataE);
    modport memory(input dataE);
endinterface

interface memory_DRAM(input word_t rd, output m_r_t mread, output m_w_t mwrite);
    modport memory();
endinterface

interface memory_wreg_writeback();
    memory_data_t dataM_new, dataM;
    modport memory(output dataM_new);
    modport wreg(input dataM_new, output dataM);
    modport writeback(input dataM);
endinterface

interface regfile_intf(output rf_w_t rfwrite);
    creg_addr_t ra1, ra2;
    word_t src1, src2;
    modport regfile(input ra1, ra2, w, output src1, src2);
    modport decode(input src1, src2, output ra1, ra2);
    modport writeback(output rfwrite);
endinterface

interface hilo_intf();
    word_t hi, lo, hi_new, lo_new;
    logic en;
    modport hilo(input hi_new, lo_new, en, output hi, lo);
    modport decode(input hi, lo);
    modport writeback(output hi_new, lo_new, en);
endinterface

interface cp0_intf();
    
    modport cp0();
    modport decode();
    modport memory();
    modport writeback();

endinterface

interface hazard_intf();
    decode_data_t dataD;
    exec_data_t dataE;
    memory_data_t dataM;
    
    logic         flushD, flushE, flushM, flushW;
    logic stallF, stallD, stallE, stallM;
    modport hazard(input dataE);
    modport freg(input stallF);
    modport dreg(input stallD, flushD);
    modport ereg(input stallE, flushE);
    modport mreg(input stallM, flushM);
    modport wreg(input flushW);
    modport decode(output dataD);
    modport execute(output dataE);
    modport memory(output dataM);
    modport exception();
endinterface

interface exception_intf();

    modport exception();
    modport cp0();
    modport memory();
endinterface

interface pcselect_intf();
    modport pcselect();
    modport fetch();
    modport decode();
    modport exception();
endinterface

`endif
