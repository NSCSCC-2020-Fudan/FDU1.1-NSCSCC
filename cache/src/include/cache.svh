`ifndef __CACHE_CACHE_SVH__
`define __CACHE_CACHE_SVH__

// 8-way 32KB 64bytes-line dual-fetch
parameter int ICACHE_IDX_BITS    = 3;  // id bits
parameter int ICACHE_INDEX_BITS  = 6;  // index bits (set)
parameter int ICACHE_OFFSET_BITS = 3;  // offset bits
parameter int ICACHE_ALIGN_BITS  = 3;  // aligned bits

// 4-way 16KB 64bytes-line
parameter int DCACHE_IDX_BITS    = 2;  // id bits
parameter int DCACHE_INDEX_BITS  = 6;  // index bits (set)
parameter int DCACHE_OFFSET_BITS = 4;  // offset bits

parameter int LSBUF_LENGTH = 8;  // length of load-store buffer for uncached ops

// for cache instruction
typedef struct packed {
    logic as_index;
    logic invalidate;
    logic writeback;
} cache_funct_t;

typedef struct packed {
    logic         req;
    cache_funct_t funct;
} cache_op_t;

`endif