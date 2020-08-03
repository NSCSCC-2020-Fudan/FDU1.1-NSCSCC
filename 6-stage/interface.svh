`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

`include "mips.svh"

interface pcselect_freg_fetch();
    word_t pc_new, pc;
    modport pcselect(output pc_new);
    modport freg(input pc_new, output pc);
    modport fetch(input pc);
endinterface

interface fetch_dreg_decode(input word_t instr_);
    fetch_data_t dataF_new, dataF;
    logic in_delay_slot;
    modport fetch(input instr_, in_delay_slot, output dataF_new);
    modport dreg(input dataF_new, output dataF);
    modport decode(input dataF, output in_delay_slot);
endinterface

interface decode_ereg_exec();
    decode_data_t dataD_new, dataD;
    logic in_delay_slot;
    modport decode(output dataD_new, input in_delay_slot);
    modport ereg(input dataD_new, output dataD);
    modport exec(input dataD, output in_delay_slot);
endinterface

interface exec_mreg_memory();
    exec_data_t dataE_new, dataE;
    modport exec(output dataE_new);
    modport mreg(input dataE_new, output dataE);
    modport memory(input dataE);
endinterface

interface memory_dram(input word_t rd, output m_r_t mread, m_w_t mwrite);
    // modport memory(input rd, output mread, mwrite);
    modport memory(output mread, mwrite, input rd);
    // modport writeback(input rd);
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
    creg_addr_t ra;
    word_t rd;
    logic is_eret, timer_interrupt;
    modport cp0(output cp0_data, rd, timer_interrupt, input cwrite, is_eret, ra);
    modport decode(input rd, cwrite, cp0_data, output ra);
    modport memory(input timer_interrupt, cwrite, output is_eret);
    modport exec(input cwrite);
    modport writeback(output cwrite);

endinterface

interface hazard_intf(input logic i_data_ok, d_data_ok, i_addr_ok, output logic stallF, flush_ex);
    decode_data_t dataD;
    exec_data_t dataE;
    mem_data_t dataM;
    wb_data_t dataW;
    // logic exception;
    logic         flushD, flushE, flushM, flushW;
    logic         stallD, stallE, stallM;
    word_t aluoutM, resultW;
    forward_t forwardAE, forwardBE, forwardAD, forwardBD;
    word_t hiM, loM, hiW, loW;
    word_t alusrcaE;
    logic is_eret;
    logic mult_ok;
    // exception_t exception;
    logic exception_valid;
    logic valid1;
    logic branchstall;
    modport hazard(input dataD, dataE, dataM, dataW, exception_valid, 
                        i_data_ok, d_data_ok, is_eret, mult_ok, i_addr_ok,
                        valid1,
                   output flushD, flushE, flushM, flushW,
                          stallF, stallD, stallE, stallM,
                          forwardAE, forwardBE, forwardAD, forwardBD,
                          aluoutM, resultW, hiM, loM, hiW, loW, flush_ex, branchstall);
    modport freg(input stallF);
    modport dreg(input stallD, flushD);
    modport ereg(input stallE, flushE);
    modport mreg(input stallM, flushM);
    modport wreg(input flushW);
    modport decode(output dataD, input aluoutM, resultW, forwardAD, forwardBD, hiM, loM, hiW, loW, alusrcaE, dataE, dataM);
    modport exec(output dataE, alusrcaE, mult_ok, input aluoutM, resultW, forwardAE, forwardBE, hiM, loM, hiW, loW);
    modport memory(output dataM, is_eret, input exception_valid);
    modport writeback(output dataW);
    modport excep(output exception_valid);
    modport fetch(input stallD, flushD, dataD, dataE, flush_ex, branchstall,
                  output valid1);
endinterface

interface exception_intf(input logic[5:0]ext_int);
    logic exception_instr, exception_ri, exception_of, exception_load, exception_save, exception_bp, exception_sys;
    interrupt_info_t interrupt_info;
    exception_t exception;
    word_t vaddr, pc;
    logic in_delay_slot;
    cp0_status_t cp0_status;
    modport excep(output exception, 
                  input exception_instr, exception_ri, exception_bp, exception_sys,
                        exception_of, exception_load, exception_save, vaddr, pc, in_delay_slot, cp0_status, interrupt_info);
    modport cp0(input exception);
    modport memory(output exception_instr, exception_ri, exception_of, exception_load, exception_save, exception_bp, exception_sys,
                          vaddr, pc, in_delay_slot, cp0_status, input ext_int, output interrupt_info);
endinterface

interface pcselect_intf();
    word_t pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F, epc;
    logic exception_valid, branch_taken, jr, jump, is_eret;
    logic stallF;
    modport pcselect(input pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F, epc,
                           exception_valid, branch_taken, jr, jump, is_eret, stallF);
    modport fetch(output pcplus4F);
    modport decode(output pcbranchD, pcjumpD, pcjrD, branch_taken, jr, jump);
    modport excep(output exception_valid, pcexception);
    modport cp0(output is_eret, epc);
    modport hazard(output stallF);
endinterface

`endif
