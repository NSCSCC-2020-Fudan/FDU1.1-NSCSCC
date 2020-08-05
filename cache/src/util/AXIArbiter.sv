`include "axi.svh"

module AXIArbiter #(
    parameter int NUM_PORTS = 3
) (
    input clk, resetn,

    input  axi_req_t  [NUM_PORTS - 1:0] m_req,
    output axi_resp_t [NUM_PORTS - 1:0] m_resp,

    output axi_req_t  s_req,
    input  axi_resp_t s_resp
);
    function logic in_issue(input axi_req_t req);
        logic __unused_ok = &{1'b0, req, 1'b0};
        return req.ar.valid || req.r.ready || req.aw.valid || req.w.valid;
    endfunction

    for (genvar i = 0; i < NUM_PORTS; i++) begin
        assign m_resp[i].b.valid = m_req[i].b.ready;
        assign m_resp[i].b.resp  = RESP_OKAY;
        assign m_resp[i].b.id    = 0;
    end

    int cur;
    assign s_req.ar = m_req[cur].ar;
    assign s_req.r  = m_req[cur].r;
    assign s_req.aw = m_req[cur].aw;
    assign s_req.w  = m_req[cur].w;

    assign s_req.b.ready = 1;

    always_comb begin
        for (int i = 0; i < NUM_PORTS; i++) begin
            if (i == cur) begin
                m_resp[i].ar = s_resp.ar;
                m_resp[i].r  = s_resp.r;
                m_resp[i].aw = s_resp.aw;
                m_resp[i].w  = s_resp.w;
            end else begin
                m_resp[i].ar = 0;
                m_resp[i].r  = 0;
                m_resp[i].aw = 0;
                m_resp[i].w  = 0;
            end
        end
    end

    always_ff @(posedge clk)
    if (resetn) begin
        if (!in_issue(m_req[cur])) begin
            for (int i = NUM_PORTS - 1; i >= 0; i--) begin
                if (in_issue(m_req[i])) begin
                    cur <= i;
                    break;
                end
            end
        end
    end else
        cur <= 0;

    logic __unused_ok = &{1'b0, s_resp.b, 1'b0};
endmodule