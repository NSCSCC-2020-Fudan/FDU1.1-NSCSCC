// `include "mips.svh"

`include "axi.svh"
`include "sramx.svh"
`include "cache_bus.svh"


// axi
module mycpu_top #(
    parameter logic USE_CACHE = 1
) (
    input logic[5:0] ext_int,  //high active

    input logic aclk,
    input logic aresetn,   //low active

    output logic [3:0] arid,
    output logic [31:0] araddr,
    output logic [3:0] arlen,
    output logic [2 :0] arsize ,
    output logic [1 :0] arburst,
    output logic [1 :0] arlock ,
    output logic [3 :0] arcache,
    output logic [2 :0] arprot ,
    output logic        arvalid,
    input logic        arready,
    input logic [3 :0] rid    ,
    input logic [31:0] rdata  ,
    input logic [1 :0] rresp  ,
    input logic        rlast  ,
    input logic        rvalid ,
    output logic        rready ,
    output logic [3 :0] awid   ,
    output logic [31:0] awaddr ,
    output logic [3 :0] awlen  ,
    output logic [2 :0] awsize ,
    output logic [1 :0] awburst,
    output logic [1 :0] awlock ,
    output logic [3 :0] awcache,
    output logic [2 :0] awprot ,
    output logic        awvalid,
    input logic        awready,
    output logic [3 :0] wid    ,
    output logic [31:0] wdata  ,
    output logic [3 :0] wstrb  ,
    output logic        wlast  ,
    output logic        wvalid ,
    input logic        wready ,
    input logic [3 :0] bid    ,
    input logic [1 :0] bresp  ,
    input logic        bvalid ,
    output logic        bready ,

    //debug interface
    output logic[31:0] debug_wb_pc,
    output logic[3:0] debug_wb_rf_wen,
    output creg_addr_t debug_wb_rf_wnum,
    output word_t debug_wb_rf_wdata
);
    /**
     * CPU instance
     */

    logic inst_req, data_req;
    logic inst_wr, data_wr;
    logic [1:0]inst_size, data_size;
    word_t inst_addr, data_addr;
    word_t inst_wdata, data_wdata;
    word_t inst_rdata, data_rdata;
    logic inst_addr_ok, data_addr_ok;
    logic inst_data_ok, data_data_ok;

    mycpu #(.DO_ADDR_TRANSLATION(~USE_CACHE)) mycpu(
        .clk(aclk), .resetn(aresetn), .ext_int,
        .inst_req, .inst_wr, .inst_size, .inst_addr, .inst_wdata, .inst_rdata, .inst_addr_ok, .inst_data_ok,
        .data_req, .data_wr, .data_size, .data_addr, .data_wdata, .data_rdata, .data_addr_ok, .data_data_ok,
        .debug_wb_pc, .debug_wb_rf_wen, .debug_wb_rf_wnum, .debug_wb_rf_wdata
    );

    if (USE_CACHE == 0) begin
        cpu_axi_interface cpu_axi_interface(
            .clk(aclk), .resetn(aresetn),
            .inst_req, .inst_wr, .inst_size, .inst_addr, .inst_wdata, .inst_rdata, .inst_addr_ok, .inst_data_ok,
            .data_req, .data_wr, .data_size, .data_addr, .data_wdata, .data_rdata, .data_addr_ok, .data_data_ok,
            .arid, .araddr, .arlen, .arsize, .arburst, .arlock, .arcache, .arprot, .arvalid , .arready,
            .rid, .rdata, .rresp, .rlast, .rvalid, .rready,
            .awid, .awaddr, .awlen, .awsize, .awburst, .awlock, .awcache, .awprot, .awvalid, .awready,
            .wid, .wdata, .wstrb, .wlast, .wvalid, .wready,
            .bid, .bresp, .bvalid, .bready
        );
    end else begin

        /**
        * cache layer
        */

        // interface converter
        sramx_req_t  imem_req,  dmem_req;
        sramx_resp_t imem_resp, dmem_resp;

        assign imem_req.req   = inst_req;
        assign imem_req.wr    = inst_wr;
        assign imem_req.size  = inst_size;
        assign imem_req.addr  = inst_addr;
        assign imem_req.wdata = inst_wdata;
        assign inst_addr_ok   = imem_resp.addr_ok;
        assign inst_data_ok   = imem_resp.data_ok;
        assign inst_rdata     = imem_resp.rdata;

        assign dmem_req.req   = data_req;
        assign dmem_req.wr    = data_wr;
        assign dmem_req.size  = data_size;
        assign dmem_req.addr  = data_addr;
        assign dmem_req.wdata = data_wdata;
        assign data_addr_ok   = dmem_resp.addr_ok;
        assign data_data_ok   = dmem_resp.data_ok;
        assign data_rdata     = dmem_resp.rdata;

        // address translation & request dispatching
        sramx_req_t  icache_req,  dcache_req,  uncached_req;
        sramx_resp_t icache_resp, dcache_resp, uncached_resp;

        MMU mmu_inst(.*);

        // naïve buffers
        cbus_req_t  icbus_req,  dcbus_req;
        cbus_resp_t icbus_resp, dcbus_resp;

        OneLineBuffer ibuf(
            .clk(aclk), .resetn(aresetn),
            .sramx_req(icache_req), .sramx_resp(icache_resp),
            .cbus_req(icbus_req), .cbus_resp(icbus_resp)
        );
        OneLineBuffer dbuf(
            .clk(aclk), .resetn(aresetn),
            .sramx_req(dcache_req), .sramx_resp(dcache_resp),
            .cbus_req(dcbus_req), .cbus_resp(dcbus_resp)
        );

        // $bus to AXI
        (*mark_debug = "true"*) axi_req_t  axi_icache_req,  axi_dcache_req;
        (*mark_debug = "true"*) axi_resp_t axi_icache_resp, axi_dcache_resp;

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

        // uncached converter
        (*mark_debug = "true"*) axi_req_t  axi_uncached_req;
        (*mark_debug = "true"*) axi_resp_t axi_uncached_resp;

        SRAMxToAXI axi_uncached_inst(
            .clk(aclk), .resetn(aresetn),
            .sramx_req(uncached_req), .sramx_resp(uncached_resp),
            .axi_req(axi_uncached_req),
            .axi_resp(axi_uncached_resp)
        );

        // AXI crossbar
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

    end
endmodule
