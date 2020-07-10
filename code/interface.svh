`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

`include "mips.svh"

interface pcselect_freg_fetch(output word_t pc_new);
    word_t pc;
    modport pcselect(output pc_new);
    modport freg(input pc_new, output pc);
    modport fetch(input pc);
endinterface

interface fetch_dreg_decode(input word_t instr_);
    fetch_data_t dataF_new, dataF;
    modport fetch(input instr_, output dataF_new);
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

interface memory_dram(input word_t rd, output m_r_t mread, output m_w_t mwrite);
    modport memory(input rd, output mread, mwrite);
endinterface

interface memory_wreg_writeback();
    mem_data_t dataM_new, dataM;
    modport memory(output dataM_new);
    modport wreg(input dataM_new, output dataM);
    modport writeback(input dataM);
endinterface

interface regfile_intf(output rf_w_t rfwrite);
    creg_addr_t ra1, ra2;
    word_t src1, src2;
    modport regfile(input ra1, ra2, rfwrite, output src1, src2);
    modport decode(input src1, src2, output ra1, ra2);
    modport writeback(output rfwrite);
endinterface

interface hilo_intf();
    word_t hi, lo;
    hilo_w_t hlwrite;
    modport hilo(input hlwrite, output hi, lo);
    modport decode(input hi, lo);
    modport writeback(output hlwrite);
endinterface

interface cp0_intf();
    rf_w_t cwrite;
    cp0_regs_t cp0_data;
    logic is_eret;
    modport cp0(output cp0_data, input cwrite, is_eret);
    modport decode(input cp0_data);
    modport memory(input cp0_data, output is_eret);
    modport writeback(output cwrite);

endinterface

interface hazard_intf(input i_data_ok);
    decode_data_t dataD;
    exec_data_t dataE;
    mem_data_t dataM;
    wb_data_t dataW;
    logic exception;
    logic         flushD, flushE, flushM, flushW;
    logic stallF, stallD, stallE, stallM;
    word_t aluoutM, resultW;
    forward_t forwardAE, forwardBE, forwardAD, forwardBD;
    // exception_t exception;
    logic exception_valid;
    modport hazard(input dataD, dataE, dataM, dataW, exception_valid, i_data_ok,
                   output flushD, flushE, flushM, flushW,
                          stallF, stallD, stallE, stallM,
                          forwardAE, forwardBE, forwardAD, forwardBD,
                          aluoutM, resultW);
    modport freg(input stallF);
    modport dreg(input stallD, flushD);
    modport ereg(input stallE, flushE);
    modport mreg(input stallM, flushM);
    modport wreg(input flushW);
    modport decode(output dataD, input aluoutM, resultW, forwardAD, forwardBD);
    modport exec(output dataE, input aluoutM, resultW, forwardAE, forwardBE);
    modport memory(output dataM);
    modport writeback(output dataW);
    modport excep(output exception_valid);
endinterface

interface exception_intf(input logic[5:0]ext_int);
    logic exception_instr, exception_ri, exception_of, exception_data, exception_bp, exception_sys;
    interrupt_info_t interrupt_info;
    exception_t exception;
    word_t vaddr, pc;
    logic in_delay_slot;
    modport excep(output exception, 
                  input exception_instr, exception_ri, exception_bp, exception_sys,
                        exception_of, exception_data, vaddr, pc, in_delay_slot);
    modport cp0(input exception);
    modport memory(output exception_instr, exception_ri, exception_of, exception_data, exception_bp, exception_sys,
                          vaddr, pc, in_delay_slot, input ext_int, output interrupt_info);
endinterface

interface pcselect_intf();
    word_t pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F;
    logic exception_valid, branch_taken, jr, jump;
    modport pcselect(input pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F,
                           exception_valid, branch_taken, jr, jump);
    modport fetch(output pcplus4F);
    modport decode(output pcbranchD, pcjumpD, pcjrD, branch_taken, jr, jump);
    modport excep(output exception_valid, pcexception);
endinterface

`endif
