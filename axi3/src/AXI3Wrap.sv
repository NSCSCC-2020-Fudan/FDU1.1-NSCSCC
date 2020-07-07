`include "workaround/AXI3WrapTop.sv"

/**
 * 将 AXI3 的 interface 直接转为龙芯提供的 `mycpu_top` 的接口。
 */
module AXI3Wrap(
    AXI3WriteAddr.Slave aw,
    AXI3Write.Slave w,
    AXI3WriteResp.Slave b,
    AXI3ReadAddr.Slave ar,
    AXI3Read.Slave r,
    output wire [3 :0] arid,
    output wire [31:0] araddr,
    output wire [3 :0] arlen,
    output wire [2 :0] arsize,
    output wire [1 :0] arburst,
    output wire [1 :0] arlock,
    output wire [3 :0] arcache,
    output wire [2 :0] arprot,
    output wire        arvalid,
    input  wire        arready,
    input  wire [3 :0] rid,
    input  wire [31:0] rdata,
    input  wire [1 :0] rresp,
    input  wire        rlast,
    input  wire        rvalid,
    output wire        rready,
    output wire [3 :0] awid,
    output wire [31:0] awaddr,
    output wire [3 :0] awlen,
    output wire [2 :0] awsize,
    output wire [1 :0] awburst,
    output wire [1 :0] awlock,
    output wire [3 :0] awcache,
    output wire [2 :0] awprot,
    output wire        awvalid,
    input  wire        awready,
    output wire [3 :0] wid,
    output wire [31:0] wdata,
    output wire [3 :0] wstrb,
    output wire        wlast,
    output wire        wvalid,
    input  wire        wready,
    input  wire [3 :0] bid,
    input  wire [1 :0] bresp,
    input  wire        bvalid,
    output wire        bready
);
    assign arid = ar.id;
    assign araddr = ar.addr;
    assign arlen = ar.len;
    assign arsize = ar.size;
    assign arburst = ar.burst;
    assign arlock = ar.lock;
    assign arcache = ar.cache;
    assign arprot = ar.prot;
    assign arvalid = ar.valid;
    assign ar.ready = arready;
    assign r.id = rid;
    assign r.data = rdata;
    assign r.resp = rresp;
    assign r.last = rlast;
    assign r.valid = rvalid;
    assign rready = r.ready;
    assign awid = aw.id;
    assign awaddr = aw.addr;
    assign awlen = aw.len;
    assign awsize = aw.size;
    assign awburst = aw.burst;
    assign awlock = aw.lock;
    assign awcache = aw.cache;
    assign awprot = aw.prot;
    assign awvalid = aw.valid;
    assign aw.ready = awready;
    assign wid = w.id;
    assign wdata = w.data;
    assign wstrb = w.strb;
    assign wlast = w.last;
    assign wvalid = w.valid;
    assign w.ready = wready;
    assign b.id = bid;
    assign b.resp = bresp;
    assign b.valid = bvalid;
    assign bready = b.ready;
endmodule