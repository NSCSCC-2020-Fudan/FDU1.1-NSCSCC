`include "data_bus.svh"
`include "cache_bus.svh"

module DCacheTop(
    input logic clk, resetn,

    input  addr_t      _dbus_req_vaddr,
    input  dbus_req_t  _dbus_req,
    output dbus_resp_t _dbus_resp,
    output cbus_req_t  _cbus_req,
    input  cbus_resp_t _cbus_resp
);
    addr_t      dbus_req_vaddr;
    dbus_req_t  dbus_req;
    dbus_resp_t dbus_resp;
    cbus_req_t  cbus_req;
    cbus_resp_t cbus_resp;

    always_ff @(posedge clk) begin
        dbus_req_vaddr <= _dbus_req_vaddr;
        dbus_req       <= _dbus_req;
        cbus_resp      <= _cbus_resp;
        _dbus_resp     <= dbus_resp;
        _cbus_req      <= cbus_req;
    end

    DCache inst(.*);
endmodule