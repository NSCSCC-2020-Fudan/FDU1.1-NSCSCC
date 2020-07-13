`ifndef __CACHE_AXI_SVH__
`define __CACHE_AXI_SVH__

`include "defs.svh"

// AXI enumerations & structs

typedef union packed {
    byte_t [3:0] bytes;
    word_t       word;
} axi_data_lanes_t;

typedef enum logic [2:0] {
    BURST_SIZE1,  BURST_SIZE2,
    BURST_SIZE4,  BURST_SIZE8,
    BURST_SIZE16, BURST_SIZE32,
    BURST_SIZE64, BURST_SIZE128
} axi_burst_size;

typedef enum logic [1:0] {
    BURST_FIXED,
    BURST_INCR,
    BURST_WRAP
} axi_burst_type;

typedef enum logic [1:0] {
    LOCK_NORMAL,
    LOCK_EX,
    LOCK_LOCKED
} axi_lock_type;

typedef enum logic [3:0] {
    MEM_DEFAULT
    // TODO: too many enums.
} axi_mem_type;

typedef struct packed {
    logic is_instr;
    logic secure;
    logic privileged;
} axi_prot_t;

typedef enum logic [1:0] {
    RESP_OKAY,
    RESP_EXOKAY,
    RESP_SLVERR,
    RESP_DECERR
} axi_resp_type;

/**
 * AXI interface
 *
 * * req(uest): master → slave
 * * resp(onse): slave → master
 */

typedef struct packed {
    id_t           id;
    addr_t         addr;
    len_t          len;   // actual length - 1
    axi_burst_size size;
    axi_burst_type burst;
    axi_lock_type  lock;
    axi_mem_type   cache;
    axi_prot_t     prot;
    logic          valid;
} axi_ar_req_t;

typedef struct packed {
    logic ready;
} axi_ar_resp_t;

typedef struct packed {
    logic ready;
} axi_r_req_t;

typedef struct packed {
    id_t             id;
    axi_data_lanes_t data;
    axi_resp_type    resp;
    logic            last;
    logic            valid;
} axi_r_resp_t;

typedef struct packed {
    id_t           id;
    addr_t         addr;
    len_t          len;
    axi_burst_size size;
    axi_burst_type burst;
    axi_lock_type  lock;
    axi_mem_type   cache;
    axi_prot_t     prot;
    logic          valid;
} axi_aw_req_t;

typedef struct packed {
    logic ready;
} axi_aw_resp_t;

typedef struct packed {
    id_t         id;
    axi_data_lanes_t data;
    strobe_t     strb;
    logic        last;
    logic        valid;
} axi_w_req_t;

typedef struct packed {
    logic ready;
} axi_w_resp_t;

typedef struct packed {
    logic ready;
} axi_b_req_t;

typedef struct packed {
    id_t          id;
    axi_resp_type resp;
    logic         valid;
} axi_b_resp_t;

typedef struct packed {
    axi_ar_req_t ar;
    axi_r_req_t  r;
    axi_aw_req_t aw;
    axi_w_req_t  w;
    axi_b_req_t  b;
} axi_req_t;

typedef struct packed {
    axi_ar_resp_t ar;
    axi_r_resp_t  r;
    axi_aw_resp_t aw;
    axi_w_resp_t  w;
    axi_b_resp_t  b;
} axi_resp_t;

`endif