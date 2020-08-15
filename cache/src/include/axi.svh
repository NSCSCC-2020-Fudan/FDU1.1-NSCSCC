`ifndef __CACHE_AXI_SVH__
`define __CACHE_AXI_SVH__

`include "defs.svh"

parameter int AXI_DATA_WIDTH = 32;
parameter int AXI_NUM_LANES  = AXI_DATA_WIDTH / 8;  // 4
parameter int AXI_LEN_BITS   = 3;  // WRAP burst workaround
parameter int AXI_MAXLEN     = 2**AXI_LEN_BITS;     // 8/16

typedef logic  [3:0]                  axi_id_t;
typedef logic  [AXI_DATA_WIDTH - 1:0] axi_word_t;
typedef logic  [AXI_LEN_BITS - 1:0]   axi_len_t;
typedef logic  [AXI_NUM_LANES - 1:0]  axi_strobe_t;
typedef byte_t [AXI_NUM_LANES - 1:0]  axi_bytes_t;

parameter axi_len_t    AXI_MAXLEN_VALUE = axi_len_t'(AXI_MAXLEN - 1);  // 7/15
parameter axi_strobe_t AXI_FULL_STROBE  = 4'b1111;

// AXI enumerations & structs

typedef union packed {
    axi_bytes_t bytes;
    axi_word_t  word;
} axi_data_lanes_t;

// NOTE: in bytes, NOT IN BITS!!!!!
typedef enum logic [2:0] {
    BURST_SIZE1   = 0,
    BURST_SIZE2   = 1,
    BURST_SIZE4   = 2,
    BURST_SIZE8   = 3,
    BURST_SIZE16  = 4,
    BURST_SIZE32  = 5,
    BURST_SIZE64  = 6,
    BURST_SIZE128 = 7
} axi_burst_size;

typedef enum logic [1:0] {
    BURST_FIXED = 2'b00,
    BURST_INCR  = 2'b01,
    BURST_WRAP  = 2'b10
} axi_burst_type;

typedef enum logic [1:0] {
    LOCK_NORMAL = 2'b00,
    LOCK_EX     = 2'b01,
    LOCK_LOCKED = 2'b10
} axi_lock_type;

typedef enum logic [3:0] {
    MEM_DEFAULT = 4'b0000
    // TODO: too many enums.
} axi_mem_type;

typedef struct packed {
    logic is_instr;
    logic secure;
    logic privileged;
} axi_prot_t;

typedef enum logic [1:0] {
    RESP_OKAY   = 2'b00,
    RESP_EXOKAY = 2'b01,
    RESP_SLVERR = 2'b10,
    RESP_DECERR = 2'b11
} axi_resp_type;

/**
 * AXI interface
 *
 * * req(uest): master → slave
 * * resp(onse): slave → master
 */

typedef struct packed {
    axi_id_t       id;
    addr_t         addr;
    axi_len_t      len;   // actual length - 1
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
    axi_id_t         id;
    axi_data_lanes_t data;
    axi_resp_type    resp;
    logic            last;
    logic            valid;
} axi_r_resp_t;

typedef struct packed {
    axi_id_t       id;
    addr_t         addr;
    axi_len_t      len;
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
    axi_id_t         id;
    axi_data_lanes_t data;
    axi_strobe_t     strb;
    logic            last;
    logic            valid;
} axi_w_req_t;

typedef struct packed {
    logic ready;
} axi_w_resp_t;

typedef struct packed {
    logic ready;
} axi_b_req_t;

typedef struct packed {
    axi_id_t      id;
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