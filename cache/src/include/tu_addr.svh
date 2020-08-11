`ifndef __CACHE_TU_ADDR_SVH__
`define __CACHE_TU_ADDR_SVH__

`include "defs.svh"

typedef struct packed {
    logic  req;
    addr_t vaddr;
} tu_addr_req_t;

typedef struct packed {
    logic  is_uncached;
    addr_t paddr;
    logic tlb_invalid; // && req
    logic tlb_modified; // && is store
} tu_addr_resp_t;

`endif