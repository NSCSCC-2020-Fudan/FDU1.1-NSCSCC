`ifndef __EXCEPTION_SVH
`define __EXCEPTION_SVH

`include "mips.svh"

`define EXC_BASE 32'hbfc0_0000
`define EXC_ENTRY 32'hbfc0_0380
typedef logic [7:0] interrupt_info_t;
typedef logic [11:0] exception_offset_t;
typedef logic[4:0] exc_code_t;
typedef struct packed {
    logic valid;
    word_t location;
    word_t pc;
    logic in_delay_slot;
    exc_code_t code;
    word_t badvaddr;
} exception_t;



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
