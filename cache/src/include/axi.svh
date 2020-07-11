`ifndef __CACHE_AXI_SVH__
`define __CACHE_AXI_SVH__

`include "defs.svh"

// AXI enumerations & structs

typedef union packed {
    byte_t [3:0] bytes;
    word_t word;
} data_lanes_t;

typedef enum logic [2:0] {
    BURST_SIZE1, BURST_SIZE2,
    BURST_SIZE4, BURST_SIZE8,
    BURST_SIZE16, BURST_SIZE32,
    BURST_SIZE64, BURST_SIZE128
} burst_size;

typedef enum logic [1:0] {
    BURST_FIXED,
    BURST_INCR,
    BURST_WRAP
} burst_type;

typedef enum logic [1:0] {
    LOCK_NORMAL,
    LOCK_EX,
    LOCK_LOCKED
} lock_type;

typedef enum logic [3:0] {
    MEM_DEFAULT
    // TODO: too many enums.
} mem_type;

typedef struct packed {
    logic is_instr;
    logic secure;
    logic privileged;
} prot_t;

typedef enum logic [1:0] {
    RESP_OKAY,
    RESP_EXOKAY,
    RESP_SLVERR,
    RESP_DECERR
} resp_type;

/**
 * AXI interface
 *
 * * req(uest): master → slave
 * * resp(onse): slave → master
 */

typedef struct packed {
    id_t id;
    addr_t addr;
    size_t len;  // actual length - 1
    burst_size size;
    burst_type burst;
    lock_type lock;
    mem_type cache;
    prot_t prot;
    logic valid;
} ar_req_t;

typedef struct packed {
    logic ready;
} ar_resp_t;

typedef struct packed {
    logic ready;
} r_req_t;

typedef struct packed {
    id_t id;
    data_lanes_t data;
    resp_type resp;
    logic last;
    logic valid;
} r_resp_t;

typedef struct packed {
    id_t id;
    addr_t addr;
    size_t len;
    burst_size size;
    burst_type burst;
    lock_type lock;
    mem_type cache;
    prot_t prot;
    logic valid;
} aw_req_t;

typedef struct packed {
    logic ready;
} aw_resp_t;

typedef struct packed {
    id_t id;
    data_lanes_t data;
    strobe_t strb;
    logic last;
    logic valid;
} w_req_t;

typedef struct packed {
    logic ready;
} w_resp_t;

typedef struct packed {
    logic ready;
} b_req_t;

typedef struct packed {
    id_t id;
    resp_type resp;
    logic valid;
} b_resp_t;

typedef struct packed {
    ar_req_t ar;
    r_req_t r;
    aw_req_t aw;
    w_req_t w;
    b_req_t b;
} axi_req_t;

typedef struct packed {
    ar_resp_t ar;
    r_resp_t r;
    aw_resp_t aw;
    w_resp_t w;
    b_resp_t b;
} axi_resp_t;

`endif