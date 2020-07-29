`include "instr_bus.svh"
`include "cache_bus.svh"

module ICacheTop(
    input logic clk, resetn,

    input  addr_t      _ibus_req_vaddr,
    input  ibus_req_t  _ibus_req,
    output ibus_resp_t _ibus_resp,
    output cbus_req_t  _cbus_req,
    input  cbus_resp_t _cbus_resp
);
    addr_t      ibus_req_vaddr;
    ibus_req_t  ibus_req;
    ibus_resp_t ibus_resp;
    cbus_req_t  cbus_req;
    cbus_resp_t cbus_resp;

    always_ff @(posedge clk) begin
        ibus_req_vaddr <= _ibus_req_vaddr;
        ibus_req       <= _ibus_req;
        cbus_resp      <= _cbus_resp;
        _ibus_resp     <= ibus_resp;
        _cbus_req      <= cbus_req;
    end

    ICache inst(.*);
endmodule