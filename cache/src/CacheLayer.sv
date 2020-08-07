`include "defs.svh"
`include "axi.svh"
`include "sramx.svh"
`include "cache_bus.svh"
`include "instr_bus.svh"
`include "data_bus.svh"
`include "cache.svh"
`include "tu.svh"

module CacheLayer #(
    parameter logic USE_ICACHE = 1,
    parameter logic USE_DCACHE = 1,
    parameter logic USE_IBUS   = 1,
    parameter logic USE_BUFFER = 1
) (
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

    // SRAMx
    input  logic        inst_req,     data_req,
    input  logic        inst_wr,      data_wr,
    input  logic  [1:0] inst_size,    data_size,
    input  addr_t       inst_addr,    data_addr,
    input  word_t       inst_wdata,   data_wdata,
    output word_t       inst_rdata,   data_rdata,
    output logic        inst_addr_ok, data_addr_ok,
    output logic        inst_data_ok, data_data_ok,

    // IBus
    input  logic        inst_ibus_req,
    input  addr_t       inst_ibus_addr,
    output logic        inst_ibus_addr_ok,
    output logic        inst_ibus_data_ok,
    output ibus_data_t  inst_ibus_data,
    output ibus_index_t inst_ibus_index,

    // TU (inside MMU)
    input  tu_op_req_t  tu_op_req,
    output tu_op_resp_t tu_op_resp
);
    /**
     * interface converter
     */
    sramx_req_t  imem_sramx_req,  dmem_req;
    sramx_resp_t imem_sramx_resp, dmem_resp;
    ibus_req_t   imem_ibus_req;
    ibus_resp_t  imem_ibus_resp;

    assign imem_sramx_req.req   = inst_req;
    assign imem_sramx_req.wr    = inst_wr;
    assign imem_sramx_req.size  = inst_size;
    assign imem_sramx_req.addr  = inst_addr;
    assign imem_sramx_req.wdata = inst_wdata;
    assign inst_addr_ok         = imem_sramx_resp.addr_ok;
    assign inst_data_ok         = imem_sramx_resp.data_ok;
    assign inst_rdata           = imem_sramx_resp.rdata;

    assign dmem_req.req   = data_req;
    assign dmem_req.wr    = data_wr;
    assign dmem_req.size  = data_size;
    assign dmem_req.addr  = data_addr;
    assign dmem_req.wdata = data_wdata;
    assign data_addr_ok   = dmem_resp.addr_ok;
    assign data_data_ok   = dmem_resp.data_ok;
    assign data_rdata     = dmem_resp.rdata;

    assign imem_ibus_req.req  = inst_ibus_req;
    assign imem_ibus_req.addr = inst_ibus_addr;
    assign inst_ibus_addr_ok  = imem_ibus_resp.addr_ok;
    assign inst_ibus_data_ok  = imem_ibus_resp.data_ok;
    assign inst_ibus_data     = imem_ibus_resp.data;
    assign inst_ibus_index    = imem_ibus_resp.index;

    addr_t imem_req_vaddr;

    if (USE_IBUS == 1)
        assign imem_req_vaddr = imem_sramx_req.addr;
    else
        assign imem_req_vaddr = imem_ibus_req.addr;

    /**
     * address translation & request dispatching
     */
    sramx_req_t  dcache_req,  uncached_req;
    sramx_resp_t dcache_resp, uncached_resp;

    // verilator lint_save
    // verilator lint_off UNUSED
    // verilator lint_off UNDRIVEN
    sramx_req_t  isramx_req;
    sramx_resp_t isramx_resp;
    ibus_req_t   ibus_req;
    ibus_resp_t  ibus_resp;
    // verilator lint_restore

    MMU #(.USE_IBUS(USE_IBUS)) mmu_inst(.*);

    /**
     * buffers or caches
     */
    cbus_req_t  icbus_req,  dcbus_req;
    cbus_resp_t icbus_resp, dcbus_resp;

    if (USE_ICACHE == 1) begin: use_icache
        addr_t      buf_ibus_req_vaddr;
        ibus_req_t  mux_ibus_req,  buf_ibus_req;
        ibus_resp_t mux_ibus_resp, buf_ibus_resp;

        if (USE_IBUS) begin
            assign mux_ibus_req  = ibus_req;
            assign ibus_resp = mux_ibus_resp;
        end else begin: sramx_to_ibus
            SRAMxToInstrBus sramx_ibus_inst(
                .sramx_req(isramx_req), .sramx_resp(isramx_resp),
                .ibus_req(mux_ibus_req), .ibus_resp(mux_ibus_resp)
            );
        end

        CacheBuffer #(
            .req_t(ibus_req_t),
            .resp_t(ibus_resp_t)
        ) icache_buf_inst(
            .clk(aclk), .resetn(aresetn),

            .m_req_vaddr(imem_req_vaddr),
            .m_req(mux_ibus_req),
            .m_resp(mux_ibus_resp),
            .s_req_vaddr(buf_ibus_req_vaddr),
            .s_req(buf_ibus_req),
            .s_resp(buf_ibus_resp)
        );

        ICache #(
            .IDX_BITS(ICACHE_IDX_BITS),
            .INDEX_BITS(ICACHE_INDEX_BITS),
            .OFFSET_BITS(ICACHE_OFFSET_BITS),
            .ALIGN_BITS(ICACHE_ALIGN_BITS)
        ) icache_inst(
            .clk(aclk), .resetn(aresetn),
            .ibus_req_vaddr(buf_ibus_req_vaddr),
            .ibus_req(buf_ibus_req),
            .ibus_resp(buf_ibus_resp),
            .cbus_req(icbus_req),
            .cbus_resp(icbus_resp)
        );
    end else begin: use_ibuf
        // NOTE: "USE_IBUS" does not affect ibuf
        OneLineBuffer ibuf_inst(
            .clk(aclk), .resetn(aresetn),
            .sramx_req(isramx_req), .sramx_resp(isramx_resp),
            .cbus_req(icbus_req), .cbus_resp(icbus_resp)
        );
    end

    if (USE_DCACHE == 1) begin: use_dcache
        addr_t      buf_dbus_req_vaddr;
        dbus_req_t  dbus_req,  buf_dbus_req;
        dbus_resp_t dbus_resp, buf_dbus_resp;

        SRAMxToDataBus sramx_dbus_inst(
            .sramx_req(dcache_req),
            .sramx_resp(dcache_resp),
            .dbus_req, .dbus_resp
        );

        CacheBuffer #(
            .req_t(dbus_req_t),
            .resp_t(dbus_resp_t)
        ) dcache_buf_inst(
            .clk(aclk), .resetn(aresetn),

            .m_req_vaddr(dmem_req.addr),
            .m_req(dbus_req),
            .m_resp(dbus_resp),
            .s_req_vaddr(buf_dbus_req_vaddr),
            .s_req(buf_dbus_req),
            .s_resp(buf_dbus_resp)
        );

        DCache #(
            .IDX_BITS(DCACHE_IDX_BITS),
            .INDEX_BITS(DCACHE_INDEX_BITS),
            .OFFSET_BITS(DCACHE_OFFSET_BITS)
        ) dcache_inst(
            .clk(aclk), .resetn(aresetn),
            .dbus_req_vaddr(buf_dbus_req_vaddr),
            .dbus_req(buf_dbus_req),
            .dbus_resp(buf_dbus_resp),
            .cbus_req(dcbus_req),
            .cbus_resp(dcbus_resp)
        );
    end else begin: use_dbuf
        OneLineBuffer dbuf_inst(
            .clk(aclk), .resetn(aresetn),
            .sramx_req(dcache_req), .sramx_resp(dcache_resp),
            .cbus_req(dcbus_req), .cbus_resp(dcbus_resp)
        );
    end

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
    sramx_req_t  mux_uncached_req;
    sramx_resp_t mux_uncached_resp;

    if (USE_BUFFER == 1) begin: with_lsbuf
        sramx_req_t  buf_uncached_req;
        sramx_resp_t buf_uncached_resp;

        LoadStoreBuffer #(
            .BUFFER_LENGTH(LSBUF_LENGTH)
        ) ls_buffer_inst(
            .clk(aclk), .resetn(aresetn),
            .m_req(uncached_req),
            .m_resp(uncached_resp),
            .s_req(buf_uncached_req),
            .s_resp(buf_uncached_resp)
        );

        assign mux_uncached_req  = buf_uncached_req;
        assign buf_uncached_resp = mux_uncached_resp;
    end else begin: without_lsbuf
        assign mux_uncached_req = uncached_req;
        assign uncached_resp    = mux_uncached_resp;
    end

    axi_req_t  axi_uncached_req;
    axi_resp_t axi_uncached_resp;

    SRAMxToAXI axi_uncached_inst(
        .clk(aclk), .resetn(aresetn),
        .sramx_req(mux_uncached_req), .sramx_resp(mux_uncached_resp),
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