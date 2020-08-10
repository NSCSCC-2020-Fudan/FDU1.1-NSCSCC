// `include "mips.svh"
`include "tu.svh"
`include "instr_bus.svh"
`include "data_bus.svh"


// axi
module mycpu_top #(
    parameter logic USE_ICACHE = 1,
    parameter logic USE_DCACHE = 1,
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
    ibus_req_t  imem_req;
    ibus_resp_t imem_resp;
    dbus_req_t  dmem_req;
    dbus_resp_t dmem_resp;

    tu_op_req_t  tu_op_req;
    tu_op_resp_t tu_op_resp;

    mycpu #(.DO_ADDR_TRANSLATION(~USE_CACHE)) mycpu(
        .clk(aclk), .resetn(aresetn), .*
    );

    CacheLayer #(
        .USE_ICACHE(USE_ICACHE),
        .USE_DCACHE(USE_DCACHE),
        .USE_BUFFER(USE_BUFFER)
    ) layer_inst(.*);
endmodule
