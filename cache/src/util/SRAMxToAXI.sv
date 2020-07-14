`include "sramx.svh"
`include "axi.svh"

module SRAMxToAXI(
    input logic clk, reset,

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
        sramx_size_t size;
        addr_t       addr;
        sramx_word_t wdata;
    } req_body_t;

    function req_body_t take_body(input sramx_req_t _req);
        logic __unused_ok = &{1'b0, _req.req, _req.wr, 1'b0};
        return {_req.size, _req.addr, _req.wdata};
    endfunction

    // indicators on channel waiting
    chan_t in_issue, next_issue, issue;
    chan_t handshake, remain;

    always_comb begin
        next_issue = 0;
        if (sramx_req.req)
            next_issue = sramx_req.wr ? 5'b00111 : 5'b11000;
    end

    // `busy`: attempt to remove one-cycle delay
    logic busy;
    assign busy = |in_issue;
    assign issue = busy ? in_issue : next_issue;

    assign handshake = {
        issue[AR] && axi_resp.ar.ready,
        issue[R ] && axi_resp.r .valid,
        issue[AW] && axi_resp.aw.ready,
        issue[W ] && axi_resp.w .ready,
        issue[B ] && axi_resp.b .valid
    };
    assign remain = issue ^ handshake;

    req_body_t saved_req, req_body;
    assign req_body = busy ? saved_req : take_body(sramx_req);

    // SRAMx driver
    assign sramx_resp.addr_ok = !busy;
    assign sramx_resp.data_ok = handshake[W] || handshake[R];
    assign sramx_resp.rdata   = axi_resp.r.data;

    // AXI driver
    axi_burst_size axi_size;
    axi_strobe_t   axi_strb;
    assign axi_size = axi_burst_size'({1'b0, req_body.size});

    always_comb
    unique case ({req_body.size, req_body.addr[1:0]})
        4'b00_00: axi_strb = 4'b0001;
        4'b00_01: axi_strb = 4'b0010;
        4'b00_10: axi_strb = 4'b0100;
        4'b00_11: axi_strb = 4'b1000;
        4'b01_00: axi_strb = 4'b0011;
        4'b01_10: axi_strb = 4'b1100;
        4'b10_00: axi_strb = 4'b1111;
        default:  axi_strb = 4'b0000;
    endcase

    always_comb begin
        axi_req = 0;

        if (issue[AR]) begin
            axi_req.ar.valid = 1;
            axi_req.ar.addr  = req_body.addr;
            axi_req.ar.size  = axi_size;
        end

        if (issue[R]) begin
            axi_req.r.ready = 1;
        end

        if (issue[AW]) begin
            axi_req.aw.valid = 1;
            axi_req.aw.addr  = req_body.addr;
            axi_req.aw.size  = axi_size;
        end

        if (issue[W]) begin
            axi_req.w.valid = 1;
            axi_req.w.data  = req_body.wdata;
            axi_req.w.strb  = axi_strb;
            axi_req.w.last  = 1;
        end

        if (issue[B]) begin
            axi_req.b.ready = 1;
        end
    end

    always_ff @(posedge clk)
    if (reset) begin
        in_issue  <= 0;
        saved_req <= 0;
    end else begin
        in_issue <= remain;
        if (!busy)
            saved_req <= take_body(sramx_req);
    end
endmodule