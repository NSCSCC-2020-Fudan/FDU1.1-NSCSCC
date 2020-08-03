`ifndef __CACHE_CACHE_SVH__
`define __CACHE_CACHE_SVH__

`include "defs.svh"

// 8-way 32KB 64bytes-line dual-fetch
parameter int ICACHE_IDX_BITS    = 3;  // id bits
parameter int ICACHE_INDEX_BITS  = 6;  // index bits (set)
parameter int ICACHE_OFFSET_BITS = 3;  // offset bits
parameter int ICACHE_ALIGN_BITS  = 3;  // aligned bits

// 8-way 32KB 64bytes-line
parameter int DCACHE_IDX_BITS    = 3;  // id bits
parameter int DCACHE_INDEX_BITS  = 6;  // index bits (set)
parameter int DCACHE_OFFSET_BITS = 4;  // offset bits

parameter int LSBUF_LENGTH = 8;  // length of load-store buffer for uncached ops

`endif