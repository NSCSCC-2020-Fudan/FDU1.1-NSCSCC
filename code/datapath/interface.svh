`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

`include "mips.svh"

interface pcs_freg();
    word_t pcnext;
    modport pcs(output pcnext);
    modport freg(input pcnext);
endinterface

interface freg_fetch(input logic clk, reset, output word_t pc);
    modport freg(input clk, reset, output pc);
    modport fetch(input pc);
endinterface

interface fetch_dreg_decode(input logic clk, reset);
    fetch_data_t dataF_new, dataF;
    modport fetch(output dataF_new);
    modport dreg(input dataF_new, clk, reset, output dataF);
    modport decode(input dataF);
endinterface

interface decode_ereg_exec(input logic clk, reset);
    decode_data_t dataD_new, dataD;
    modport decode(output dataD_new);
    modport ereg(input dataD_new, clk, reset, output dataD);
    modport exec(input dataD);
endinterface

interface exec_mreg_memory(input logic clk, reset);
    exec_data_t dataE_new, dataE;
    modport exec(output dataE_new);
    modport mreg(input dataE_new, clk, reset, output dataE);
    modport memory(input dataE);
endinterface

interface memory_wreg_writeback(input logic clk, reset);
    memory_data_t dataM_new, dataM;
    modport memory(output dataM_new);
    modport wreg(input dataM_new, clk, reset, output dataM);
    modport writeback(input dataM);
endinterface

interface regfile_intf(input logic clk, reset);
    creg_addr_t ra1, ra2;
    word_t src1, src2;
    w_rf_t w;
    modport rf(input clk, reset, ra1, ra2, w, output src1, src2);
    modport decode(input src1, src2, output ra1, ra2);
    modport writeback(output w);
endinterface

interface hilo_intf(input logic clk, reset);
    word_t hi, lo, hi_new, lo_new;
    logic en;
    modport hilo(input clk, reset, hi_new, lo_new, en, output hi, lo);
    modport decode(input hi, lo);
    modport writeback(output hi_new, lo_new, en);
endinterface

interface cp0_intf();
    
endinterface

interface hazard_intf();
    
endinterface

interface exception_intf();
    
endinterface

`endif
