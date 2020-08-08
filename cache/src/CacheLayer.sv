`include "defs.svh"
`include "axi.svh"
`include "cache_bus.svh"
`include "instr_bus.svh"
`include "data_bus.svh"
`include "cache.svh"
`include "tu.svh"

module CacheLayer(
    input  logic aclk, aresetn,

    // AXI3
    output logic [3:0]  arid,
    output logic [31:0] araddr,
    output logic [3:0]  arlen,
    output logic [2 :0] arsize,
    output logic [1 :0] arburst,
    output logic [1 :0] arlock,
    output logic [3 :0] arcache,
    output logic [2 :0] arprot,
    output logic        arvalid,
    input  logic        arready,
    input  logic [3 :0] rid,
    input  logic [31:0] rdata,
    input  logic [1 :0] rresp,
    input  logic        rlast,
    input  logic        rvalid,
    output logic        rready,
    output logic [3 :0] awid,
    output logic [31:0] awaddr,
    output logic [3 :0] awlen,
    output logic [2 :0] awsize,
    output logic [1 :0] awburst,
    output logic [1 :0] awlock,
    output logic [3 :0] awcache,
    output logic [2 :0] awprot,
    output logic        awvalid,
    input  logic        awready,
    output logic [3 :0] wid,
    output logic [31:0] wdata,
    output logic [3 :0] wstrb,
    output logic        wlast,
    output logic        wvalid,
    input  logic        wready,
    input  logic [3 :0] bid,
    input  logic [1 :0] bresp,
    input  logic        bvalid,
    output logic        bready,

    // CPU requests
    input  ibus_req_t  imem_req,
    output ibus_resp_t imem_resp,
    input  dbus_req_t  dmem_req,
    output dbus_resp_t dmem_resp,

    // TU (inside MMU)
    input  tu_op_req_t  tu_op_req,
    output tu_op_resp_t tu_op_resp
);
    /**
     * address translations & request dispatching
     */
    ibus_req_t  icache_req;
    ibus_resp_t icache_resp;
    dbus_req_t  dcache_req,  uncached_req;
    dbus_resp_t dcache_resp, uncached_resp;

    MMU mmu_inst(.*);

    /**
     * buffers or caches
     */
    cbus_req_t  icbus_req,  dcbus_req;
    cbus_resp_t icbus_resp, dcbus_resp;

    // ICache
    addr_t      buf_imem_req_vaddr;
    ibus_req_t  buf_icache_req;
    ibus_resp_t buf_icache_resp;

    CacheBuffer #(
        .req_t(ibus_req_t),
        .resp_t(ibus_resp_t)
    ) icache_buf_inst(
        .clk(aclk), .resetn(aresetn),

        .m_req_vaddr(imem_req.addr),
        .m_req(icache_req),
        .m_resp(icache_resp),
        .s_req_vaddr(buf_imem_req_vaddr),
        .s_req(buf_icache_req),
        .s_resp(buf_icache_resp)
    );

    ICache #(
        .IDX_BITS(ICACHE_IDX_BITS),
        .INDEX_BITS(ICACHE_INDEX_BITS),
        .OFFSET_BITS(ICACHE_OFFSET_BITS),
        .ALIGN_BITS(ICACHE_ALIGN_BITS)
    ) icache_inst(
        .clk(aclk), .resetn(aresetn),

        .ibus_req_vaddr(buf_imem_req_vaddr),
        .ibus_req(buf_icache_req),
        .ibus_resp(buf_icache_resp),
        .cbus_req(icbus_req),
        .cbus_resp(icbus_resp)
    );

    // DCache
    addr_t      buf_dmem_req_vaddr;
    dbus_req_t  buf_dcache_req;
    dbus_resp_t buf_dcache_resp;

    CacheBuffer #(
        .req_t(dbus_req_t),
        .resp_t(dbus_resp_t)
    ) dcache_buf_inst(
        .clk(aclk), .resetn(aresetn),

        .m_req_vaddr(dmem_req.addr),
        .m_req(dcache_req),
        .m_resp(dcache_resp),
        .s_req_vaddr(buf_dmem_req_vaddr),
        .s_req(buf_dcache_req),
        .s_resp(buf_dcache_resp)
    );

    DCache #(
        .IDX_BITS(DCACHE_IDX_BITS),
        .INDEX_BITS(DCACHE_INDEX_BITS),
        .OFFSET_BITS(DCACHE_OFFSET_BITS)
    ) dcache_inst(
        .clk(aclk), .resetn(aresetn),

        .dbus_req_vaddr(buf_dmem_req_vaddr),
        .dbus_req(buf_dcache_req),
        .dbus_resp(buf_dcache_resp),
        .cbus_req(dcbus_req),
        .cbus_resp(dcbus_resp)
    );

    /**
     * $bus to AXI
     */
    axi_req_t  axi_icache_req,  axi_dcache_req;
    axi_resp_t axi_icache_resp, axi_dcache_resp;

    CacheBusToAXI axi_icache_inst(
        .clk(aclk), .resetn(aresetn),
        .cbus_req(icbus_req), .cbus_resp(icbus_resp),
        .axi_req(axi_icache_req),
        .axi_resp(axi_icache_resp)
    );
    CacheBusToAXI axi_dcache_inst(
        .clk(aclk), .resetn(aresetn),
        .cbus_req(dcbus_req), .cbus_resp(dcbus_resp),
        .axi_req(axi_dcache_req),
        .axi_resp(axi_dcache_resp)
    );

    /**
     * uncached converter
     */
    dbus_req_t  buf_uncached_req;
    dbus_resp_t buf_uncached_resp;

    LoadStoreBuffer #(
        .BUFFER_LENGTH(LSBUF_LENGTH)
    ) ls_buffer_inst(
        .clk(aclk), .resetn(aresetn),

        .m_req(uncached_req),
        .m_resp(uncached_resp),
        .s_req(buf_uncached_req),
        .s_resp(buf_uncached_resp)
    );

    axi_req_t  axi_uncached_req;
    axi_resp_t axi_uncached_resp;

    DataBusToAXI axi_uncached_inst(
        .clk(aclk), .resetn(aresetn),
        .dbus_req(buf_uncached_req),
        .dbus_resp(buf_uncached_resp),
        .axi_req(axi_uncached_req),
        .axi_resp(axi_uncached_resp)
    );

    /**
     * AXI crossbar
     */
    logic [11:0] s_axi_awid;
    logic [95:0] s_axi_awaddr;
    logic [11:0] s_axi_awlen;
    logic [8 :0] s_axi_awsize;
    logic [5 :0] s_axi_awburst;
    logic [5 :0] s_axi_awlock;
    logic [11:0] s_axi_awcache;
    logic [8 :0] s_axi_awprot;
    logic [11:0] s_axi_awqos;
    logic [2 :0] s_axi_awvalid;
    logic [2 :0] s_axi_awready;
    logic [11:0] s_axi_wid;
    logic [95:0] s_axi_wdata;
    logic [11:0] s_axi_wstrb;
    logic [2 :0] s_axi_wlast;
    logic [2 :0] s_axi_wvalid;
    logic [2 :0] s_axi_wready;
    logic [11:0] s_axi_bid;
    logic [5 :0] s_axi_bresp;
    logic [2 :0] s_axi_bvalid;
    logic [2 :0] s_axi_bready;
    logic [11:0] s_axi_arid;
    logic [95:0] s_axi_araddr;
    logic [11:0] s_axi_arlen;
    logic [8 :0] s_axi_arsize;
    logic [5 :0] s_axi_arburst;
    logic [5 :0] s_axi_arlock;
    logic [11:0] s_axi_arcache;
    logic [8 :0] s_axi_arprot;
    logic [11:0] s_axi_arqos;
    logic [2 :0] s_axi_arvalid;
    logic [2 :0] s_axi_arready;
    logic [11:0] s_axi_rid;
    logic [95:0] s_axi_rdata;
    logic [5 :0] s_axi_rresp;
    logic [2 :0] s_axi_rlast;
    logic [2 :0] s_axi_rvalid;
    logic [2 :0] s_axi_rready;

    logic [3:0] awqos, arqos;  // ignored

    CrossbarWrap _wrap_inst(
        .*,
        .req({
            axi_uncached_req,
            axi_dcache_req,
            axi_icache_req
        }),
        .resp({
            axi_uncached_resp,
            axi_dcache_resp,
            axi_icache_resp
        })
    );

`ifndef VERILATOR
    AXICrossbar crossbar_inst(
        .*,
        .aclk(aclk), .aresetn(aresetn),

        .m_axi_awid(awid),
        .m_axi_awaddr(awaddr),
        .m_axi_awlen(awlen),
        .m_axi_awsize(awsize),
        .m_axi_awburst(awburst),
        .m_axi_awlock(awlock),
        .m_axi_awcache(awcache),
        .m_axi_awprot(awprot),
        .m_axi_awqos(awqos),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),

        .m_axi_wid(wid),
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),

        .m_axi_bid(bid),
        .m_axi_bresp(bresp),
        .m_axi_bvalid(bvalid),
        .m_axi_bready(bready),

        .m_axi_arid(arid),
        .m_axi_araddr(araddr),
        .m_axi_arlen(arlen),
        .m_axi_arsize(arsize),
        .m_axi_arburst(arburst),
        .m_axi_arlock(arlock),
        .m_axi_arcache(arcache),
        .m_axi_arprot(arprot),
        .m_axi_arqos(arqos),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),

        .m_axi_rid(rid),
        .m_axi_rdata(rdata),
        .m_axi_rresp(rresp),
        .m_axi_rlast(rlast),
        .m_axi_rvalid(rvalid),
        .m_axi_rready(rready)
    );
`else
    assign {
        arid, araddr, arlen, arsize, arburst, arlock,
        arcache, arprot, arvalid, rready, awid, awaddr,
        awlen, awsize, awburst, awlock, awcache, awprot,
        awvalid, wid, wdata, wstrb, wlast, wvalid, bready,
        s_axi_awready, s_axi_awready, s_axi_bid, s_axi_bvalid,
        s_axi_wready, s_axi_bresp, s_axi_arready, s_axi_rid,
        s_axi_rdata, s_axi_rresp, s_axi_rlast, s_axi_rvalid,
        awqos, arqos
    } = 0;

    logic __unused_ok = &{1'b0,
        s_axi_awid, s_axi_awaddr, s_axi_awlen, s_axi_awsize,
        s_axi_awburst, s_axi_awlock, s_axi_awcache, s_axi_awprot,
        s_axi_awqos, s_axi_awvalid, s_axi_awready, s_axi_wid,
        s_axi_wdata, s_axi_wstrb, s_axi_wlast, s_axi_wvalid,
        s_axi_wready, s_axi_bid, s_axi_bresp, s_axi_bvalid,
        s_axi_bready, s_axi_arid, s_axi_araddr, s_axi_arlen,
        s_axi_arsize, s_axi_arburst, s_axi_arlock, s_axi_arcache,
        s_axi_arprot, s_axi_arqos, s_axi_arvalid, s_axi_arready,
        s_axi_rid, s_axi_rdata, s_axi_rresp, s_axi_rlast,
        s_axi_rvalid, s_axi_rready, awqos, arqos,
        arid, araddr, arlen, arsize, arburst, arlock,
        arcache, arprot, arvalid, arready, rid, rdata, rresp,
        rlast, rvalid, rready, awid, awaddr, awlen, awsize,
        awburst, awlock, awcache, awprot, awvalid, awready,
        wid, wdata, wstrb, wlast, wvalid, wready, bid, bresp,
        bvalid, bready,
    1'b0};
`endif
endmodule