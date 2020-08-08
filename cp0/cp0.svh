`ifndef __CP0_SVH
`define __CP0_SVH

typedef logic [4:0] cp0_addr_t;

parameter TLB_INDEX = 3;
typedef struct packed {
    logic P;                    // 31, Probe Failure, R
    logic [30:TLB_INDEX] zero;  // [30:n], always 0
    logic [TLB_INDEX-1:0]index; // [n-1:0], TLB index, R/W
} cp0_index_t;

typedef struct packed {
    logic [31:TLB_INDEX] zero;
    logic [TLB_INDEX-1:0] random; // TLB Random Index, R
                                  // with special upper and lower bound 
} cp0_random_t;

parameter PABITS = 16;          // physical address bits
typedef struct packed {
    logic [31:PABITS - 6] fill;     // always 0, R
    logic [PABITS-7:6] PFN;         // page frame number, R/W
    logic [2:0] C;                  // Cacheability and Coherency Attribute of the page R/W
    logic D;                        // Dirty bit, R/W
    logic V;                        // Valid bit, R/W
    logic G;                        // Global bit, R/W
} cp0_entrylo_t;

typedef struct packed {
    logic[8:0]PTEbase;              // Page Table Entry, R/W

    logic[18:0]badVPN2;
    // This field is written by hardware on a TLB exception. 
    // It contains bits VA 31..13 of the virtual address that caused the exception.
    // R

    logic[3:0]zero;
} cp0_context_t;

typedef struct packed {
    logic[2:0]zero_0;
    logic[15:0]mask;
    /*
    The Mask field is a bit mask in which a “1” bit
    indicates that the corresponding bit of the vir-
    tual address should not participate in the TLB
    match.
    R/W
    */
    logic[12:0]zero_1;
} cp0_pagemask_t;

typedef struct packed {
    logic[31:TLB_INDEX]zero;
    logic[TLB_INDEX-1:0]wired; // TLB wired boundary, R/W
} cp0_wired_t;

typedef struct packed {
    logic[18:0]VPN2;
    /*
    VA 31..13 of the virtual address (virtual page number / 2).
    This field is written by hardware on a TLB exception or
    on a TLB read, and is written by software before a TLB
    write.
    R/W
    */
    logic[4:0]zero;
    logic[7:0]ASID;
    /*
    Address space identifier. This field is written by hard-
    ware on a TLB read and by software to establish the cur-
    rent ASID value for TLB write and against which TLB
    references match each entry’s TLB ASID field.
    R/W
    */
} cp0_entryhi_t;

typedef struct packed {
    logic M;        // 31, reset as 1
    logic [2:0]K23; // [30:28], fixed mapping MMU?, R/W
    logic [2:0]KU;  // [27:25], fixed mapping MMU?, R/W
    logic [9:0]zero_0; // [24:10]
    logic [2:0]MT;  // [9:7] MMU Type, R
    logic [2:0]zero_1; // [6:4]
    logic VI;       // 3, Virtual instruction cache, R
    logic [2:0]K0; // [2:0] Kseg0 cacheability and coherency attribute, R/W
} cp0_config_t;

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
    word_t config_1; // preset
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
        lladdr;     // 17, Load linked address
    cp0_config_t
        config_;    // 16, Configuration register
    word_t 
        prid,       // 15, Processor identification and revision
        epc;        // 14, Program counter at last exception, R/W
    cp0_cause_t 
        cause;      // 13, Cause of last general exception
    cp0_status_t
        status;     // 12, Processor status and control
    word_t
        compare;    // 11, Timer interrupt control, R/W, normally write only
    cp0_entryhi_t
        entryhi;    // 10, High-order portion of the TLB entry
    word_t
        count,      // 09, Processor cycle count, R/W
        badvaddr,   // 08, Reports the address for the most recent address-related exception, R
        hwrena;     // 07, Enables access via the RDHWR instruction to selected hardware registers
    cp0_wired_t
        wired;      // 06, Controls the number of fixed ("wired") TLB entries
    cp0_pagemask_t    
        pagemask;   // 05, Control for variable page size in TLB entries
    cp0_context_t
        context_;   // 04, Pointer to page table entry in memory
    cp0_entrylo_t
        entrylo1,   // 03, Low-order portion of the TLB entry for odd-numbered virtual pages
        entrylo0;   // 02, Low-order portion of the TLB entry for even-numbered virtual pages
    cp0_random_t    
        random;     // 01, Randomly generated index into the TLB array
    cp0_index_t
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
};

`define EXC_BASE 32'hbfc0_0000
`define EXC_ENTRY 32'hbfc0_0380
typedef logic [7:0] interrupt_info_t;
typedef logic [11:0] exception_offset_t;
typedef logic[4:0] exc_code_t;
typedef struct packed {
    logic mod;
    logic instr;
    logic instr_tlb;
    logic load;
    logic save;
    logic load_tlb;
    logic save_tlb;
    logic sys;
    logic bp;
    logic ri;
    logic cpu;
    logic of;
    logic tr;
} exception_info_t;
typedef struct packed {
    logic valid;
    word_t location;
    word_t pc;
    logic in_delay_slot;
    exc_code_t code;
    word_t badvaddr;
} exception_t;

typedef struct packed{
    logic exception_instr, exception_ri, exception_of;
    logic exception_load, exception_bp, exception_sys, exception_save;
    logic in_delay_slot;
    interrupt_info_t interrupt_info; 
    word_t vaddr, pc;
} exception_pipeline_t;

`define CODE_INT   5'h00  // Interrupt
`define CODE_MOD   5'h01  // TLB modification exception
`define CODE_TLBL  5'h02  // TLB exception (load or instruction fetch)
`define CODE_TLBS  5'h03  // TLB exception (store)
`define CODE_ADEL  5'h04  // Address exception (load or instruction fetch)
`define CODE_ADES  5'h05  // Address exception (store)
`define CODE_SYS   5'h08  // Syscall
`define CODE_BP    5'h09  // Breakpoint
`define CODE_RI    5'h0a  // Reserved Instruction exception
`define CODE_CPU   5'h0b  // CoProcesser Unusable exception
`define CODE_OV    5'h0c  // OVerflow
`define CODE_TR    5'h0d  // TRap

`endif
