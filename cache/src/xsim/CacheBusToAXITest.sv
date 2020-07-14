`ifndef VERILATOR

`include "axi.svh"
`include "cache_bus.svh"

module CacheBusToAXITest();
    logic clk = 0;
    always #10 clk = ~clk;

    logic reset = 0, resetn;
    assign resetn = ~reset;

    cbus_req_t cbus_req;
    cbus_resp_t cbus_resp;
    axi_req_t axi_req;
    axi_resp_t axi_resp;

    typedef logic [1:0] u2_t;
    typedef logic [2:0] u3_t;
    u2_t rresp, bresp;
    assign axi_resp.r.resp = axi_resp_type'(rresp);
    assign axi_resp.b.resp = axi_resp_type'(bresp);
    wire [4 :0] ram_random_mask;

    `define RANDOM_SEED {7'b1010101,16'habcd}
    reg [22:0] pseudo_random_23;
    reg        no_mask;     //if led_r_n is all 1, no mask
    reg        short_delay; //memory long delay
    always @ (posedge clk)
    begin
    if (!resetn)
        pseudo_random_23 <= `RANDOM_SEED;
    else
        pseudo_random_23 <= {pseudo_random_23[21:0],pseudo_random_23[22] ^ pseudo_random_23[17]};

    if(!resetn)
        no_mask <= pseudo_random_23[15:0]==16'h00FF;

    if(!resetn)
        short_delay <= pseudo_random_23[7:0]==8'hFF;
    end
    assign ram_random_mask[0] = (pseudo_random_23[10]&pseudo_random_23[20]) & (short_delay|(pseudo_random_23[11]^pseudo_random_23[5]))
                            | no_mask;
    assign ram_random_mask[1] = (pseudo_random_23[ 9]&pseudo_random_23[17]) & (short_delay|(pseudo_random_23[12]^pseudo_random_23[4]))
                            | no_mask;
    assign ram_random_mask[2] = (pseudo_random_23[ 8]^pseudo_random_23[22]) & (short_delay|(pseudo_random_23[13]^pseudo_random_23[3]))
                            | no_mask;
    assign ram_random_mask[3] = (pseudo_random_23[ 7]&pseudo_random_23[19]) & (short_delay|(pseudo_random_23[14]^pseudo_random_23[2]))
                            | no_mask;
    assign ram_random_mask[4] = (pseudo_random_23[ 6]^pseudo_random_23[16]) & (short_delay|(pseudo_random_23[15]^pseudo_random_23[1]))
                            | no_mask;

    CacheBusToAXI inst(.*);
    logic rsta_busy, rstb_busy;
    axi_wrap_ram u_axi_ram
    (
        .rsta_busy       ( rsta_busy ),
        .rstb_busy       ( rstb_busy ),
        .aclk            ( clk ),
        .aresetn         ( resetn),
        .axi_arid        ( axi_req.ar.id ),
        .axi_araddr      ( axi_req.ar.addr ),
        .axi_arlen       ( {4'd0,axi_req.ar.len[3:0]} ),
        .axi_arsize      ( axi_req.ar.size),
        .axi_arburst     ( axi_req.ar.burst ),
        .axi_arlock      ( axi_req.ar.lock ),
        .axi_arcache     ( axi_req.ar.cache ),
        .axi_arprot      ( axi_req.ar.prot ),
        .axi_arvalid     ( axi_req.ar.valid ),
        .axi_arready     ( axi_resp.ar.ready ),
        .axi_rid         ( axi_resp.r.id ),
        .axi_rdata       ( axi_resp.r.data ),
        .axi_rresp       ( rresp ),
        .axi_rlast       ( axi_resp.r.last ),
        .axi_rvalid      ( axi_resp.r.valid ),
        .axi_rready      ( axi_req.r.ready ),
        .axi_awid        ( axi_req.aw.id ),
        .axi_awaddr      ( axi_req.aw.addr ),
        .axi_awlen       ( {4'd0,axi_req.aw.len[3:0]} ),
        .axi_awsize      ( axi_req.aw.size),
        .axi_awburst     ( axi_req.aw.burst ),
        .axi_awlock      ( axi_req.aw.lock ),
        .axi_awcache     ( axi_req.aw.cache ),
        .axi_awprot      ( axi_req.aw.prot ),
        .axi_awvalid     ( axi_req.aw.valid),
        .axi_awready     ( axi_resp.aw.ready ),
        .axi_wid         ( axi_req.w.id ),
        .axi_wdata       ( axi_req.w.data ),
        .axi_wstrb       ( axi_req.w.strb ),
        .axi_wlast       ( axi_req.w.last ),
        .axi_wvalid      ( axi_req.w.valid ),
        .axi_wready      ( axi_resp.w.ready ),
        .axi_bid         ( axi_resp.b.id ),
        .axi_bresp       ( bresp ),
        .axi_bvalid      ( axi_resp.b.valid ),
        .axi_bready      ( axi_req.b.ready ),
        .ram_random_mask ( ram_random_mask )
    );

    logic [31:0] data = 32'h12345678;
    always_ff @(posedge clk)
    if (cbus_resp.okay)
        data <= data + 1;
    assign cbus_req.wdata = data;

    initial begin
        reset = 1;
    #120
        reset = 0;
    #120
    #137
        cbus_req.valid    = 1;
        cbus_req.is_write = 1;
        cbus_req.addr     = 0;
        cbus_req.order    = 5;
        while (!cbus_resp.last) begin
            #10 /* spin wait */;
        end
        cbus_req.valid = 0;
    #40
        cbus_req.valid    = 1;
        cbus_req.is_write = 0;
        cbus_req.addr     = 0;
        cbus_req.order    = 3;
        while (!cbus_resp.last) begin
            #20 /* spin wait */;
        end
        cbus_req.valid = 0;
    #40
        cbus_req.valid    = 1;
        cbus_req.is_write = 0;
        cbus_req.addr     = 4;
        cbus_req.order    = 5;
        while (!cbus_resp.last) begin
            #20 /* spin wait */;
        end
        cbus_req.valid = 0;
    #40
        cbus_req.valid    = 1;
        cbus_req.is_write = 1;
        cbus_req.addr     = 16;
        cbus_req.order    = 5;
        while (!cbus_resp.last) begin
            #20 /* spin wait */;
        end
        cbus_req.valid = 0;
    #40
        cbus_req.valid    = 1;
        cbus_req.is_write = 0;
        cbus_req.addr     = 0;
        cbus_req.order    = 6;
        while (!cbus_resp.last) begin
            #20 /* spin wait */;
        end
        cbus_req.valid = 0;
    #80
        $finish;
    end
endmodule


`endif