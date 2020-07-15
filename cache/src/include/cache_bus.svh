`ifndef __CACHE_CACHE_BUS_SVH__
`define __CACHE_CACHE_BUS_SVH__

`include "defs.svh"

// NOTE: `CBUS_LEN_BITS` must be greater than `AXI_LEN_BITS`.
parameter int CBUS_DATA_WIDTH = 32;
parameter int CBUS_DATA_BYTES = CBUS_DATA_WIDTH / 8;     // 4
parameter int CBUS_LEN_BITS   = 16;
parameter int CBUS_MAXLEN     = 2**(CBUS_LEN_BITS - 1);  // 2^15 = 32768
parameter int CBUS_ORDER_BITS = $clog2(CBUS_LEN_BITS);   // 4

typedef logic [CBUS_DATA_WIDTH - 1:0] cbus_word_t;
typedef logic [CBUS_LEN_BITS - 1:0]   cbus_len_t;
typedef logic [CBUS_ORDER_BITS - 1:0] cbus_order_t;

typedef union packed {
    byte_t [CBUS_DATA_BYTES - 1:0] bytes;
    cbus_word_t                    word;
} cbus_view_t;

typedef struct packed {
    logic        valid;
    logic        is_write;
    addr_t       addr;
    cbus_order_t order;
    cbus_view_t  wdata;
} cbus_req_t;

typedef struct packed {
    logic       okay;
    logic       last;
    cbus_view_t rdata;
} cbus_resp_t;

`endif