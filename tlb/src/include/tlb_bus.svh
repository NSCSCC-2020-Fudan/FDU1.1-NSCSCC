`ifndef TLB_WITHOUT_MIPS
`include "mips.svh"
`endif

`ifndef __TLB_BUS_SVH__
`define __TLB_BUS_SVH__

`define SPLIT_MODE 1

parameter int TLB_VPN2_BITS     = 19;
parameter int TLB_PFN_BITS      = 20;
parameter int TLB_OFFSET_BITS     = 32 - TLB_PFN_BITS;
parameter int TLB_ASID_BITS     = 8;
parameter int TLB_CC_BITS       = 3; // cache coherency field
parameter int TLB_MASK_BITS     = 16; // pagemask
parameter int TLB_PHY_NUM_WAYS  = 2;
`ifdef SPLIT_MODE
parameter int TLB_ENTRIES_NUM   = 16;
parameter int TLB_INDEX_BITS    = $clog2(TLB_ENTRIES_NUM) + 1; // split into inst and data
`else
parameter int TLB_ENTRIES_NUM   = 32;
parameter int TLB_INDEX_BITS    = $clog2(TLB_ENTRIES_NUM);
`endif

typedef logic [TLB_VPN2_BITS  - 1:0] tlb_vpn2_t;
typedef logic [TLB_PFN_BITS   - 1:0] tlb_pfn_t;
typedef logic [TLB_ASID_BITS  - 1:0] tlb_asid_t;
typedef logic [TLB_CC_BITS    - 1:0] tlb_cc_t;
typedef logic [TLB_MASK_BITS  - 1:0] tlb_mask_t;
typedef logic [TLB_INDEX_BITS - 1:0] tlb_idx_t;

typedef struct packed {
    logic [31-TLB_OFFSET_BITS:0]    page;
    logic [TLB_OFFSET_BITS-1:0]     offset;
} tlb_addr_t;

typedef struct packed {
    logic                         p;
    logic [30 - TLB_INDEX_BITS:0] padding;
    tlb_idx_t                     idx;
} tlb_index_t;

typedef struct packed {
    logic [2:0]     paddinghi;
    tlb_mask_t      mask;
    logic [12:0]    paddinglo;
} tlb_pagemask_t;

typedef struct packed {
    logic [5:0] padding;
    tlb_pfn_t   pfn;
    tlb_cc_t    cc;
    logic       d;
    logic       v;
    logic       g;
} tlb_entrylo_t;

typedef struct packed {
    tlb_vpn2_t vpn2;
    logic [4:0] padding;
    tlb_asid_t asid;
} tlb_entryhi_t;

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
    tlb_index_t     index;
    tlb_transec_t   transec;
    word_t          phys_addr;
} tlb_result_t;

`endif