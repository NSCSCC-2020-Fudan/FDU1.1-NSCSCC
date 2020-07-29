`include "axi.svh"

module AXIWrap(
    input  axi_req_t  req,
    output axi_resp_t resp,

    // AR channel
    output logic [3:0]  arid,
    output logic [31:0] araddr,
    output logic [3:0]  arlen,
    output logic [2:0]  arsize,
    output logic [1:0]  arburst,
    output logic [1:0]  arlock,
    output logic [3:0]  arcache,
    output logic [2:0]  arprot,
    output logic        arvalid,
    input  logic        arready,

    // R channel
    input  logic [3:0]  rid,
    input  logic [31:0] rdata,
    input  logic [1:0]  rresp,
    input  logic        rlast,
    input  logic        rvalid,
    output logic        rready,

    // AW channel
    output logic [3:0]  awid,
    output logic [31:0] awaddr,
    output logic [3:0]  awlen,
    output logic [2:0]  awsize,
    output logic [1:0]  awburst,
    output logic [1:0]  awlock,
    output logic [3:0]  awcache,
    output logic [2:0]  awprot,
    output logic        awvalid,
    input  logic        awready,

    // W channel
    output logic [3:0]  wid,
    output logic [31:0] wdata,
    output logic [3:0]  wstrb,
    output logic        wlast,
    output logic        wvalid,
    input  logic        wready,

    // B channel
    input  logic [3:0] bid,
    input  logic [1:0] bresp,
    input  logic       bvalid,
    output logic       bready
);
    // AR channel
    assign {
        arid, araddr, arlen, arsize,
        arburst, arlock, arcache,
        arprot, arvalid
    } = {
        req.ar.id, req.ar.addr, req.ar.len, req.ar.size,
        req.ar.burst, req.ar.lock, req.ar.cache,
        req.ar.prot, req.ar.valid
    };
    assign resp.ar.ready = arready;

    // R channel
    assign {
        resp.r.id, resp.r.data, resp.r.resp,
        resp.r.last, resp.r.valid
    } = {
        rid, rdata, rresp, rlast, rvalid
    };
    assign rready = req.r.ready;

    // AW channel
    assign {
        awid, awaddr, awlen, awsize,
        awburst, awlock, awcache,
        awprot, awvalid
    } = {
        req.aw.id, req.aw.addr, req.aw.len,
        req.aw.size, req.aw.burst,
        req.aw.lock, req.aw.cache,
        req.aw.prot, req.aw.valid
    };
    assign resp.aw.ready = awready;

    // W channel
    assign {
        wid, wdata, wstrb, wlast,
        wvalid
    } = {
        req.w.id, req.w.data, req.w.strb, req.w.last,
        req.w.valid
    };
    assign resp.w.ready = wready;

    // B channel
    assign {
        resp.b.id, resp.b.resp,
        resp.b.valid
    } = {bid, bresp, bvalid};
    assign bready = req.b.ready;
endmodule