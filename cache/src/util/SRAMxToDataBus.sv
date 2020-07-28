`include "sramx.svh"
`include "data_bus.svh"

module SRAMxToDataBus(
    input  sramx_req_t  sramx_req,
    output sramx_resp_t sramx_resp,
    output dbus_req_t   dbus_req,
    input  dbus_resp_t  dbus_resp
);
    assign dbus_req.valid    = sramx_req.req;
    assign dbus_req.is_write = sramx_req.wr;
    assign dbus_req.addr     = sramx_req.addr;
    assign dbus_req.data     = sramx_req.wdata;

    StrobeTranslator _strobe_inst(
        .size(sramx_req.size),
        .offset(sramx_req.addr[1:0]),
        .strobe(dbus_req.write_en)
    );

    assign sramx_resp.addr_ok = dbus_resp.addr_ok;
    assign sramx_resp.data_ok = dbus_resp.data_ok;
    assign sramx_resp.rdata   = dbus_resp.data;
endmodule