`include "include/common.svh"
`include "include/enums.svh"

interface AXI3WriteResp(input logic clk, resetn);
    nibble_t id;
    Response resp;
    logic valid;
    logic ready;

    modport Master(
        input clk, resetn,
        input id, resp,
        input valid,
        output ready
    );
    modport Slave(
        input clk, resetn,
        output id, resp,
        output valid,
        input ready
    );
endinterface