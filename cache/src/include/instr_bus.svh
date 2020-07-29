`ifndef __CACHE_INSTR_BUS_SVH__
`define __CACHE_INSTR_BUS_SVH__

`include "defs.svh"

parameter int IBUS_DATA_WIDTH = 64;
parameter int IBUS_WORD_WIDTH = 32;
parameter int IBUS_WORD_PER_BUS = IBUS_DATA_WIDTH / IBUS_WORD_WIDTH;
parameter int IBUS_INDEX_WIDTH = $clog2(IBUS_WORD_PER_BUS);

typedef logic [IBUS_DATA_WIDTH - 1:0] ibus_data_t;
typedef logic [IBUS_INDEX_WIDTH - 1:0] ibus_index_t;

typedef struct packed {
    logic  req;
    addr_t addr;
} ibus_req_t;

typedef struct packed {
    logic        addr_ok;
    logic        data_ok;
    ibus_data_t  data;
    ibus_index_t index;
} ibus_resp_t;

`endif