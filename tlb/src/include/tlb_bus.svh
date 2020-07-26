`ifndef TLB_WITHOUT_MIPS
`include "mips.svh"
`endif

`ifndef __TLB_BUS_SVH__
`define __TLB_BUS_SVH__

`define SPLIT_MODE 1

parameter int TLB_VPN2_BITS     = 19;
parameter int TLB_PFN_BITS      = 20;
parameter int TLB_ASID_BITS     = 8;
parameter int TLB_CC_BITS       = 3; // cache coherency field
parameter int TLB_MASK_BITS     = 16; // pagemask
parameter int TLB_PHY_NUM_WAYS  = 2;
`ifdef SPLIT_MODE
parameter int TLB_ENTRIES_NUM   = 16;
`else
parameter int TLB_ENTRIES_NUM   = 32;
`endif

typedef logic [TLB_VPN2_BITS - 1:0] tlb_vpn2_t;
typedef logic [TLB_PFN_BITS  - 1:0] tlb_pfn_t;
typedef logic [TLB_ASID_BITS - 1:0] tlb_asid_t;
typedef logic [TLB_CC_BITS   - 1:0] tlb_cc_t;
typedef logic [TLB_MASK_BITS - 1:0] tlb_mask_t;
typedef word_t                      tlb_virt_t;
typedef word_t                      tlb_phys_t;

typedef struct packed {
    tlb_mask_t  pagemask;
    tlb_vpn2_t  vpn2;
    logic       g;
    tlb_asid_t  asid;
} tlb_compsec_t;

typedef struct packed {
    tlb_pfn_t pfn;
    tlb_cc_t  c;
    logic     d;
    logic     v;
} tlb_transec_t;

typedef struct packed {
    tlb_compsec_t compsec;
    tlb_transec_t [TLB_PHY_NUM_WAYS - 1:0] transec;
} tlb_entry_t;

typedef struct packed {
    tlb_transec_t 
} tlb_result_t;

`endif