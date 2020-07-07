`include "include/common.svh"
`include "include/enums.svh"

interface AXI3WriteAddr(input logic clk, resetn);
    nibble_t id;
    word_t addr;
    nibble_t len;
    BurstSize size;
    BurstType burst;
    LockType lock;
    MemoryType cache;
    Protection prot;
    logic valid;
    logic ready;

    modport Master(
        input clk, resetn,
        output id, addr, len, size, burst, lock, cache, prot,
        output valid,
        input ready
    );
    modport Slave(
        input clk, resetn,
        input id, addr, len, size, burst, lock, cache, prot,
        input valid,
        output ready
    );
endinterface