`include "sramx.svh"
`include "instr_bus.svh"

/**
 * NOTE: this bus converter does not fully utilize
 *       the maximum bandwidth of IBus.
 */
module InstrBusToSRAMx(
    input  ibus_req_t   ibus_req,
    output ibus_resp_t  ibus_resp,
    output sramx_req_t  sramx_req,
    input  sramx_resp_t sramx_resp
);
    assign sramx_req.req   = ibus_req.req;
    assign sramx_req.wr    = 0;
    assign sramx_req.size  = sramx_size_t'(SRAMX_MAX_SIZE);
    assign sramx_req.addr  = ibus_req.addr;
    assign sramx_req.wdata = 0;

    assign ibus_resp.addr_ok = sramx_resp.addr_ok;
    assign ibus_resp.data_ok = sramx_resp.data_ok;
    assign ibus_resp.index   = {IBUS_INDEX_WIDTH{1'b1}};
    assign ibus_resp.data    = {
        sramx_resp.rdata,
        {(IBUS_DATA_WIDTH - SRAMX_DATA_WIDTH){1'b0}}
    };
endmodule