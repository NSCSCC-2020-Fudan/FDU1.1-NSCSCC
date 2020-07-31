// `include "mips.svh"


// axi
module mycpu_top #(
    parameter logic USE_CACHE  = 1,
    parameter logic USE_ICACHE = 1,
    parameter logic USE_DCACHE = 1,
    parameter logic USE_IBUS   = 1,
    parameter logic USE_BUFFER = 1
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

    localparam int _IBUS_DATA_WIDTH = 64;
    localparam int _IBUS_INDEX_BITS = $clog2(_IBUS_DATA_WIDTH / 32);
    typedef logic [_IBUS_DATA_WIDTH - 1:0] _ibus_data_t;
    typedef logic [_IBUS_INDEX_BITS - 1:0] _ibus_index_t;
    logic         inst_ibus_req;
    addr_t        inst_ibus_addr;
    logic         inst_ibus_addr_ok;
    logic         inst_ibus_data_ok;
    _ibus_data_t  inst_ibus_data;
    _ibus_index_t inst_ibus_index;

    mycpu #(.DO_ADDR_TRANSLATION(~USE_CACHE)) mycpu(
        .clk(aclk), .resetn(aresetn), .*
    );

    if (USE_CACHE == 0) begin: without_cache
        logic mux_inst_req;
        logic mux_inst_wr;
        logic [1:0]mux_inst_size;
        word_t mux_inst_addr;
        word_t mux_inst_wdata;
        word_t mux_inst_rdata;
        logic mux_inst_addr_ok;
        logic mux_inst_data_ok;

        if (USE_IBUS == 1) begin
            assign mux_inst_req   = inst_ibus_req;
            assign mux_inst_wr    = 0;
            assign mux_inst_size  = 2;
            assign mux_inst_addr  = inst_ibus_addr;
            assign mux_inst_wdata = 0;
            assign inst_ibus_addr_ok = mux_inst_addr_ok;
            assign inst_ibus_data_ok = mux_inst_data_ok;
            assign inst_ibus_index   = 1'b1;
            assign inst_ibus_data    = {
                mux_inst_rdata, 32'b0
            };
        end else begin
            assign mux_inst_req = inst_req;
            assign mux_inst_wr = inst_wr;
            assign mux_inst_size = inst_size;
            assign mux_inst_addr = inst_addr;
            assign mux_inst_wdata = inst_wdata;
            assign inst_rdata = mux_inst_rdata;
            assign inst_addr_ok = mux_inst_addr_ok;
            assign inst_data_ok = mux_inst_data_ok;
        end

        cpu_axi_interface cpu_axi_interface(
            .clk(aclk), .resetn(aresetn),
            .inst_req(mux_inst_req), .inst_wr(mux_inst_wr), .inst_size(mux_inst_size), .inst_addr(mux_inst_addr), .inst_wdata(mux_inst_wdata), .inst_rdata(mux_inst_rdata), .inst_addr_ok(mux_inst_addr_ok), .inst_data_ok(mux_inst_data_ok),
            .data_req, .data_wr, .data_size, .data_addr, .data_wdata, .data_rdata, .data_addr_ok, .data_data_ok,
            .arid, .araddr, .arlen, .arsize, .arburst, .arlock, .arcache, .arprot, .arvalid , .arready,
            .rid, .rdata, .rresp, .rlast, .rvalid, .rready,
            .awid, .awaddr, .awlen, .awsize, .awburst, .awlock, .awcache, .awprot, .awvalid, .awready,
            .wid, .wdata, .wstrb, .wlast, .wvalid, .wready,
            .bid, .bresp, .bvalid, .bready
        );
    end else begin: with_cache
        CacheLayer #(
            .USE_ICACHE(USE_ICACHE),
            .USE_DCACHE(USE_DCACHE),
            .USE_IBUS(USE_IBUS),
            .USE_BUFFER(USE_BUFFER)
        ) layer_inst(.*);
    end
endmodule
