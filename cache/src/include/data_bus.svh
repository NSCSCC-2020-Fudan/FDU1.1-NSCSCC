`ifndef __CACHE_DATA_BUS_SVH__
`define __CACHE_DATA_BUS_SVH__

`include "defs.svh"

parameter int DBUS_DATA_WIDTH = 32;
parameter int DBUS_DATA_BYTES = DBUS_DATA_WIDTH / 8;

typedef logic  [DBUS_DATA_BYTES - 1:0] dbus_wrten_t;
typedef byte_t [DBUS_DATA_BYTES - 1:0] dbus_bytes_t;
typedef logic  [DBUS_DATA_WIDTH - 1:0] dbus_word_t;

typedef union packed {
    dbus_bytes_t bytes;
    dbus_word_t word;
} dbus_view_t;

typedef struct packed {
    logic        req;
    logic        is_write;
    dbus_wrten_t write_en;
    addr_t       addr;
    dbus_view_t  data;
} dbus_req_t;

typedef struct packed {
    logic       addr_ok;
    logic       data_ok;
    dbus_view_t data;
} dbus_resp_t;

`endif