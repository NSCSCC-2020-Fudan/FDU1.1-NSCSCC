`include "include/common.svh"
`include "include/enums.svh"

interface AXI3Read(input logic clk, resetn);
    nibble_t id;
    word_t data;
    Response resp;
    logic last;
    logic valid;
    logic ready;

    modport Master(
        input clk, resetn,
        input id, data, resp, last,
        input valid,
        output ready
    );
    modport Slave(
        input clk, resetn,
        output id, data, resp, last,
        output valid,
        input ready
    );
endinterface