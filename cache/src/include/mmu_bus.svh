`ifndef TLB_WITHOUT_MIPS
`include "mips.svh"
`endif

`ifndef __MMU_BUS_SVH__
`define __MMU_BUS_SVH__

`include "tlb_bus.svh"

typedef struct packed {
    logic       invalid;
    logic       modified;
    logic       miss;
    tlb_addr_t  phys_addr;
    tlb_addr_t  virt_addr;
} mmu_result_t;

`endif