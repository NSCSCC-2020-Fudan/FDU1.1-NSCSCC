`ifndef __AXI3_ENUMS_SVH
`define __AXI3_ENUMS_SVH

typedef enum logic [2:0] {
    BURST_SIZE1, BURST_SIZE2,
    BURST_SIZE4, BURST_SIZE8,
    BURST_SIZE16, BURST_SIZE32,
    BURST_SIZE64, BURST_SIZE128
} BurstSize;

typedef enum logic [1:0] {
    BURST_TYPE_FIXED,
    BURST_TYPE_INCR,
    BURST_TYPE_WRAP
} BurstType;

typedef enum logic [1:0] {
    LOCK_NORMAL,
    LOCK_EX,
    LOCK_LOCKED
} LockType;

typedef enum logic [3:0] {
    MEM_DEFAULT
    // TODO: too many enums.
} MemoryType;

typedef struct packed {
    logic is_instr;
    logic secure;
    logic privileged;
} Protection;

typedef enum logic [1:0] {
    RESP_OKAY,
    RESP_EXOKAY,
    RESP_SLVERR,
    RESP_DECERR
} Response;

`endif