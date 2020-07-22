`ifndef __CACHE_CACHE_SVH__
`define __CACHE_CACHE_SVH__

`include "defs.svh"

parameter int ICACHE_IDX_BITS    = 3;  // id bits
parameter int ICACHE_INDEX_BITS  = 6;  // index bits (set)
parameter int ICACHE_OFFSET_BITS = 3;  // offset bits
parameter int ICACHE_ALIGN_BITS  = 3;  // aligned bits

`endif