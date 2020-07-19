`ifndef __CACHE_ICACHE_SVH__
`define __CACHE_ICACHE_SVH__

`include "defs.svh"

parameter int ICACHE_ALIGN_BITS  = 3;                      // aligned bits
parameter int ICACHE_DATA_BYTES  = 2**ICACHE_ALIGN_BITS;   // BRAM data width in bytes
parameter int ICACHE_DATA_BITS   = ICACHE_DATA_BYTES * 8;  // BRAM data width in bits
parameter int ICACHE_OFFSET_BITS = 3;                      // pffset bits
parameter int ICACHE_INDEX_BITS  = 6;                      // index bits (set)
parameter int ICACHE_IDX_BITS    = 3;                      // id bits
parameter int ICACHE_NUM_WAYS    = 2**ICACHE_IDX_BITS;     // degree of associativity

// NOTE: in order to utilize VIPT, ICACHE_NONTAG_BITS must be within 4KB page.
parameter int ICACHE_NONTAG_BITS = ICACHE_ALIGN_BITS + ICACHE_OFFSET_BITS + ICACHE_INDEX_BITS;
parameter int ICACHE_TAG_BITS    = BITS_PER_WORD - ICACHE_NONTAG_BITS;

typedef logic [ICACHE_OFFSET_BITS - 1:0] icache_offset_t;
typedef logic [ICACHE_INDEX_BITS  - 1:0] icache_index_t;
typedef logic [ICACHE_IDX_BITS    - 1:0] icache_idx_t;
typedef logic [ICACHE_TAG_BITS    - 1:0] icache_tag_t;

// icache expects 8 bytes alignment, but also accepts addr[2] as strb.
// therefore, only the last two bits need to be zeros.
typedef logic [ICACHE_ALIGN_BITS  - 2:0] icache_zeros_t;

typedef struct packed {
    logic          strb;
    icache_zeros_t zeros;  // expected to be zeros
} icache_align_t;

typedef struct packed {
    icache_tag_t    tag;
    icache_index_t  index;
    icache_offset_t offset;
    icache_align_t  aligned;
} icache_addr_t;

typedef struct packed {
    icache_idx_t    idx;
    icache_index_t  index;
    icache_offset_t offset;
} icache_iaddr_t;

typedef struct packed {
    logic        valid;
    icache_tag_t tag;
} icache_line_t;

typedef struct packed {
    logic         [ICACHE_NUM_WAYS - 2:0] select;  // for tree-based pLRU
    icache_line_t [ICACHE_NUM_WAYS - 1:0] lines;
} icache_set_t;

`endif