`ifndef __CP0_SVH
`define __CP0_SVH

`include "mips.svh"
typedef logic [4:0] cp0_addr_t;

typedef struct packed {
    logic BD;           // 31, Branch Delay Slot. Updated only if status.exl is 0. R
    logic TI;           // 30, Timer Interrupt. R
    logic [1:0] CE;     // [29:28], cp number when the coprocessor is unusable. Always 0 in this work.
    logic DC;           // 27, Disable Count register. Always 0 in this work.
    logic PCI;          // 26, Performance Counter Interrupt. Always 0 in this work.
    logic [1:0] ASE_0;  // [25:24], reserved for the MCU ASE. Always 0 in this work.
    logic IV;           // 23, 0: general(0x180); 1: special(0x200). Always 0 in this work.
    logic WP;           // 22, Watch Exception. Always 0 in this work.
    logic FDCI;         // 21, Fase Debug Channel Interrupt. Always 0 in this work.
    logic [2:0] zero_0; // [20:18]
    logic [1:0] ASE_1;  // [17:16], reserved for the MCU ASE. Always 0 in this work.
    logic [7:0] IP;     // [15:8], Interrupt Pending. [7:2] R, [1:0] R/W
    logic zero_1;       // 7
    logic [4:0] exccode;// [6:2], Exception Code. R
    logic [1:0] zero_2; // [1:0]
} cp0_cause_t;

typedef struct packed {
    logic [3:0] CU;     // [31:28], access to cp unit 3 to 0. Always 0 in this work.
    logic RP;           // 27, Reduced Rower mode. Always 0 in this work.
    logic FR;           // 26, Floating point Register mode. Always 0 in this work.
    logic RE;           // 25, Reverse Endian. Always 0 in this work.
    logic MX;           // 24, MDMX and MIPS DSP. Always 0 in this work.
    logic zero_0;       // 23
    logic BEV;          // 22, location of exception vectors. Always 1 in this work.
    logic TS;           // 21, mutiple TLB entries. Always 0 in this work.
    logic SR;           // 20, Soft Reset. Always 0 in this work.
    logic NMI;          // 19, reset due to NMI exception. Always 0 in this work.
    logic ASE;          // 18, reserved for ASE. Always 0 in this work.
    logic [1:0] IMPL;   // [17:16], implementation dependent. Always 0 in this work.
    logic [7:0] IM;     // [15:8], Interrupt Mask. R/W
    logic [2:0] zero_1; // [7:5]
    logic UM;           // 4, 0: Kernel Mode. 1: User Mode. Always 0 in this work.
    logic R0;           // 3, reserved. Always 0 in this work.
    logic ERL;          // 2, Error Level. Always 0 in this work.
    logic EXL;          // 1, Exception Level. R/W
    logic IE;           // 0, Interrupt Enable. R/W
} cp0_status_t;

typedef struct packed {
word_t 
    desave,     // 31, EJTAG debug exception save register
    errorepc,   // 30, Program counter at last error
    taghi,      // 29, High-order portion of cache tag interface
    taglo,      // 28, Low-order portion of cache tag interface
    cacheerr,   // 27, Cache parity error control and status
    errctl,     // 26, Parity/ECC error control and status
    perfcnt,    // 25, Performance counter interface
    depc,       // 24, Program counter at last EJTAG debug exception 
    debug,      // 23, EJTAG Debug register
    reserved22, // 22, reserved
    reserved21, // 21, reserved
    reserved20, // 20, reserved
    watchhi,    // 19, Watchpoint control
    watchlo,    // 18, Watchpoint address
    lladdr,     // 17, Load linked address
    config_,    // 16, Configuration register
    prid,       // 15, Processor identification and revision
    epc;        // 14, Program counter at last exception, R/W
cp0_cause_t
    cause;      // 13, Cause of last general exception
cp0_status_t
    status;     // 12, Processor status and control
word_t
    compare,    // 11, Timer interrupt control, R/W, normally write only
    entryhi,    // 10, High-order portion of the TLB entry
    count,      // 09, Processor cycle count, R/W
    badvaddr,   // 08, Reself the address for the most recent address-related exception, R
    hwrena,     // 07, Enables access via the RDHWR instruction to selected hardware registers
    wired,      // 06, Controls the number of fixed (“wired”) TLB entries
    pagemask,   // 05, Control for variable page size in TLB entries
    context_,   // 04, Pointer to page table entry in memory
    entrylo1,   // 03, Low-order portion of the TLB entry for odd-numbered virtual pages
    entrylo0,   // 02, Low-order portion of the TLB entry for even-numbered virtual pages
    random,     // 01, Randomly generated index into the TLB array
    index;       // 00, Index into the TLB array
} cp0_regs_t;

`define CP0_INIT {                                      \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0000_0000_0100_0000_0000_0000_0000_0000,        \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0                                               \
}

`endif
