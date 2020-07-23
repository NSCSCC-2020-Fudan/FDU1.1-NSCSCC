`include "sramx.svh"
`include "instr_bus.svh"

/**
 * NOTE: IBus does not allow write operations
 */
module SRAMxToInstrBus(
    input  sramx_req_t  sramx_req,
    output sramx_resp_t sramx_resp,
    output ibus_req_t   ibus_req,
    input  ibus_resp_t  ibus_resp
);
    assign ibus_req.req       = sramx_req.req;
    assign ibus_req.addr      = sramx_req.addr;
    assign sramx_resp.addr_ok = ibus_resp.addr_ok;
    assign sramx_resp.data_ok = ibus_resp.data_ok;

    typedef logic [IBUS_DATA_WIDTH:1] ibus_view_t;
    ibus_view_t data_view = ibus_resp.data;
    assign sramx_resp.rdata   = data_view[
        {ibus_resp.index, {SRAMX_DATA_BITS{1'b0}}} -: SRAMX_DATA_WIDTH
    ];

    logic __unused_ok = &{1'b0, sramx_req, 1'b0};
endmodule