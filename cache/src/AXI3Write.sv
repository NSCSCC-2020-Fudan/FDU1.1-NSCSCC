`include "include/common.svh"
`include "include/enums.svh"

interface AXI3Write(input logic clk, resetn);
    nibble_t id;
    word_t data;
    nibble_t strb;
    logic last;
    logic valid;
    logic ready;

    modport Master(
        input clk, resetn,
        output id, data, strb, last,
        output valid,
        input ready
    );
    modport Slave(
        input clk, resetn,
        input id, data, strb, last,
        input valid,
        output ready
    );
endinterface