`include "axi.svh"

module CrossbarWrap(
    input  axi_req_t  [2:0] req,
    output axi_resp_t [2:0] resp,

    output logic [11:0] s_axi_awid,
    output logic [95:0] s_axi_awaddr,
    output logic [11:0] s_axi_awlen,
    output logic [8 :0] s_axi_awsize,
    output logic [5 :0] s_axi_awburst,
    output logic [5 :0] s_axi_awlock,
    output logic [11:0] s_axi_awcache,
    output logic [8 :0] s_axi_awprot,
    output logic [11:0] s_axi_awqos,
    output logic [2 :0] s_axi_awvalid,
    input  logic [2 :0] s_axi_awready,

    output logic [11:0] s_axi_wid,
    output logic [95:0] s_axi_wdata,
    output logic [11:0] s_axi_wstrb,
    output logic [2 :0] s_axi_wlast,
    output logic [2 :0] s_axi_wvalid,
    input  logic [2 :0] s_axi_wready,

    input  logic [11:0] s_axi_bid,
    input  logic [5 :0] s_axi_bresp,
    input  logic [2 :0] s_axi_bvalid,
    output logic [2 :0] s_axi_bready,

    output logic [11:0] s_axi_arid,
    output logic [95:0] s_axi_araddr,
    output logic [11:0] s_axi_arlen,
    output logic [8 :0] s_axi_arsize,
    output logic [5 :0] s_axi_arburst,
    output logic [5 :0] s_axi_arlock,
    output logic [11:0] s_axi_arcache,
    output logic [8 :0] s_axi_arprot,
    output logic [11:0] s_axi_arqos,
    output logic [2 :0] s_axi_arvalid,
    input  logic [2 :0] s_axi_arready,

    input  logic [11:0] s_axi_rid,
    input  logic [95:0] s_axi_rdata,
    input  logic [5 :0] s_axi_rresp,
    input  logic [2 :0] s_axi_rlast,
    input  logic [2 :0] s_axi_rvalid,
    output logic [2 :0] s_axi_rready
);
    `define pack(obj, chan, sig) \
        {obj[2].chan.sig, obj[1].chan.sig, obj[0].chan.sig}

    assign s_axi_awid    = `pack(req, aw, id   );
    assign s_axi_awaddr  = `pack(req, aw, addr );
    assign s_axi_awlen   = `pack(req, aw, len  );
    assign s_axi_awsize  = `pack(req, aw, size );
    assign s_axi_awburst = `pack(req, aw, burst);
    assign s_axi_awlock  = `pack(req, aw, lock );
    assign s_axi_awcache = `pack(req, aw, cache);
    assign s_axi_awprot  = `pack(req, aw, prot );
    assign s_axi_awqos   = '0;
    assign s_axi_awvalid = `pack(req, aw, valid);
    assign `pack(resp, aw, ready) = s_axi_awready;

    assign s_axi_wid    = `pack(req, w, id   );
    assign s_axi_wdata  = `pack(req, w, data );
    assign s_axi_wstrb  = `pack(req, w, strb );
    assign s_axi_wlast  = `pack(req, w, last );
    assign s_axi_wvalid = `pack(req, w, valid);
    assign `pack(resp, w, ready) = s_axi_wready;

    assign `pack(resp, b, id   ) = s_axi_bid;
    assign `pack(resp, b, resp ) = s_axi_bresp;
    assign `pack(resp, b, valid) = s_axi_bvalid;
    assign s_axi_bready = `pack(req, b, ready);

    assign s_axi_arid    = `pack(req, ar, id   );
    assign s_axi_araddr  = `pack(req, ar, addr );
    assign s_axi_arlen   = `pack(req, ar, len  );
    assign s_axi_arsize  = `pack(req, ar, size );
    assign s_axi_arburst = `pack(req, ar, burst);
    assign s_axi_arlock  = `pack(req, ar, lock );
    assign s_axi_arcache = `pack(req, ar, cache);
    assign s_axi_arprot  = `pack(req, ar, prot );
    assign s_axi_arqos   = '0;
    assign s_axi_arvalid = `pack(req, ar, valid);
    assign `pack(resp, ar, ready) = s_axi_arready;

    assign `pack(resp, r, id   ) = s_axi_rid;
    assign `pack(resp, r, data ) = s_axi_rdata;
    assign `pack(resp, r, resp ) = s_axi_rresp;
    assign `pack(resp, r, last ) = s_axi_rlast;
    assign `pack(resp, r, valid) = s_axi_rvalid;
    assign s_axi_rready = `pack(req, r, ready);
endmodule