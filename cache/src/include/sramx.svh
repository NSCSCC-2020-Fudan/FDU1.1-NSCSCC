`ifndef __CACHE_SRAMX_SVH__
`define __CACHE_SRAMX_SVH__

`include "defs.svh"

parameter int SRAMX_DATA_WIDTH = 32;
parameter int SRAMX_SIZE_WIDTH = 2;
parameter int SRAMX_DATA_BYTES = SRAMX_DATA_WIDTH / 8;  // 4

typedef logic [SRAMX_DATA_WIDTH - 1:0] sramx_word_t;
typedef logic [SRAMX_SIZE_WIDTH - 1:0] sramx_size_t;

typedef union packed {
    byte_t [SRAMX_DATA_BYTES - 1:0] bytes;
    sramx_word_t                    word;
} sramx_view_t;

typedef struct packed {
    logic        req;
    logic        wr;
    sramx_size_t size;
    addr_t       addr;
    sramx_view_t wdata;
} sramx_req_t;

typedef struct packed {
    logic        addr_ok;
    logic        data_ok;
    sramx_view_t rdata;
} sramx_resp_t;

`endif