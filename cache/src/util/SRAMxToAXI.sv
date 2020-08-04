`include "sramx.svh"
`include "axi.svh"

module SRAMxToAXI(
    input logic clk, resetn,

    input  sramx_req_t  sramx_req,
    output sramx_resp_t sramx_resp,
    output axi_req_t    axi_req,
    input  axi_resp_t   axi_resp
);
    localparam int AR = 4;
    localparam int R  = 3;
    localparam int AW = 2;
    localparam int W  = 1;
    localparam int B  = 0;
    typedef logic [4:0] chan_t;

    typedef struct packed {
        addr_t         addr;
        axi_burst_size size;
        axi_strobe_t   strb;
        axi_word_t     wdata;
    } req_t;

    // parse request
    axi_strobe_t   axi_strb;
    axi_burst_size axi_size;

    assign axi_size = axi_burst_size'({1'b0, sramx_req.size});

    StrobeTranslator _strobe_inst(
        .size(sramx_req.size),
        .offset(sramx_req.addr[1:0]),
        .strobe(axi_strb)
    );

    req_t new_req;
    assign new_req.addr  = sramx_req.addr;
    assign new_req.size  = axi_size;
    assign new_req.strb  = axi_strb;
    assign new_req.wdata = sramx_req.wdata;

    chan_t next_issue;
    assign next_issue = sramx_req.wr ? 5'b00111 : 5'b11000;

    // interactions with AXI
    chan_t in_issue;
    req_t  saved_req;

    logic  busy;
    chan_t handshake, remain;

    assign busy = |in_issue;
    assign handshake = {
        in_issue[AR] && axi_resp.ar.ready,
        in_issue[R ] && axi_resp.r .valid,
        in_issue[AW] && axi_resp.aw.ready,
        in_issue[W ] && axi_resp.w .ready,
        in_issue[B ] && axi_resp.b .valid
    };
    assign remain = in_issue ^ handshake;

    // SRAMx driver
    assign sramx_resp.addr_ok = !busy;
    assign sramx_resp.data_ok = handshake[W] || handshake[R];
    assign sramx_resp.rdata   = axi_resp.r.data;

    // AXI driver
    always_comb begin
        axi_req = 0;

        if (in_issue[AR]) begin
            axi_req.ar.valid = 1;
            axi_req.ar.addr  = saved_req.addr;
            axi_req.ar.size  = saved_req.size;
        end

        if (in_issue[R]) begin
            axi_req.r.ready = 1;
        end

        if (in_issue[AW]) begin
            axi_req.aw.valid = 1;
            axi_req.aw.addr  = saved_req.addr;
            axi_req.aw.size  = saved_req.size;
        end

        if (in_issue[W]) begin
            axi_req.w.valid = 1;
            axi_req.w.data  = saved_req.wdata;
            axi_req.w.strb  = saved_req.strb;
            axi_req.w.last  = 1;
        end

        if (in_issue[B]) begin
            axi_req.b.ready = 1;
        end
    end

    always_ff @(posedge clk)
    if (resetn) begin
        if (busy)
            in_issue <= remain;
        else begin
            if (sramx_req.req)
                in_issue <= next_issue;
            saved_req <= new_req;
        end
    end else begin
        in_issue  <= 0;
    end
endmodule