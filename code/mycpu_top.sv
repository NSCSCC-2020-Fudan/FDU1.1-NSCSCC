`include "mips.svh"

// sram
module mycpu(
    input logic clk,
    input logic resetn,  //low active
    input logic[5:0] ext_int,  //interrupt,high active

    output logic inst_req, data_req,
    output logic inst_wr, data_wr,
    output logic [1:0]inst_size, data_size,
    output word_t inst_addr, data_addr,
    output word_t inst_wdata, data_wdata,
    input word_t inst_rdata, data_rdata,
    input logic inst_addr_ok, data_addr_ok,
    input logic inst_data_ok, data_data_ok,

    //debug
    output word_t debug_wb_pc,
    output rwen_t debug_wb_rf_wen,
    output creg_addr_t debug_wb_rf_wnum,
    output word_t debug_wb_rf_wdata
);
    m_r_t mread;
    m_w_t mwrite;
    rf_w_t rfwrite;
    logic stallF;
    logic clk_;
    // always_ff @( posedge clk) begin
    //     clk_ <=  clk & inst_addr_ok & (inst_data_ok | ~inst_req) & (data_data_ok | ~data_req) & inst_data_ok;
    // end
    assign clk_ = clk;
    word_t vaddr;
    logic i_data_ok, d_data_ok;
    datapath datapath(.clk(clk_), .reset(~resetn), .ext_int, 
                      .pc(inst_addr), .instr_(inst_rdata),
                      .mread, .mwrite, .rfwrite, .rd(data_rdata), .wb_pc(debug_wb_pc),
                      .stallF, .i_data_ok, .d_data_ok);

    // assign inst_req = 1'b1;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_wdata = '0;
    handshake i_handshake(.clk, .reset(~resetn), .cpu_req(1'b1), .addr_ok(inst_addr_ok), .data_ok(inst_data_ok), .cpu_data_ok(i_data_ok), .req(inst_req));
    // assign data_req = (|mread.ren) | (|mwrite.wen);
    assign data_wr = mwrite.wen;
    assign vaddr = (mwrite.wen) ? mwrite.addr : mread.addr;
    always_comb begin
        case (vaddr[31:28])
            4'h8: data_addr[31:28] = 4'b0;
            4'h9: data_addr[31:28] = 4'b1;
            4'ha: data_addr[31:28] = 4'b0;
            4'hb: data_addr[31:28] = 4'b1;
            default: begin
                data_addr[31:28] = vaddr[31:28];
            end
        endcase
    end
    always_comb begin
        
    end
    assign data_addr[27:0] = vaddr[27:0];
    assign data_wdata = mwrite.wd;
    assign data_size = mwrite.wen ? mwrite.size : mread.size;
    handshake d_handshake(.clk, .reset(~resetn), .cpu_req(mread.ren|mwrite.wen), .addr_ok(data_addr_ok), .data_ok(data_data_ok), .cpu_data_ok(d_data_ok), .req(data_req));

    assign debug_wb_rf_wen = {4{rfwrite.wen && (rfwrite.addr != 0)}};
    assign debug_wb_rf_wnum = rfwrite.addr;
    assign debug_wb_rf_wdata = rfwrite.wd;
endmodule


// axi
module mycpu_top (
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
    logic inst_req, data_req;
    logic inst_wr, data_wr;
    logic [1:0]inst_size, data_size;
    word_t inst_addr, data_addr;
    word_t inst_wdata, data_wdata;
    word_t inst_rdata, data_rdata;
    logic inst_addr_ok, data_addr_ok;
    logic inst_data_ok, data_data_ok;
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
    mycpu mycpu(
        .clk(aclk), .resetn(aresetn), .ext_int,
        .inst_req, .inst_wr, .inst_size, .inst_addr, .inst_wdata, .inst_rdata, .inst_addr_ok, .inst_data_ok,
        .data_req, .data_wr, .data_size, .data_addr, .data_wdata, .data_rdata, .data_addr_ok, .data_data_ok,
        .debug_wb_pc, .debug_wb_rf_wen, .debug_wb_rf_wnum, .debug_wb_rf_wdata
    );
endmodule
