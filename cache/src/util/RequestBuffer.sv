`include "sramx.svh"

/**
 * to remove combinatorial circuits between requests & "addr_ok".
 */
module RequestBuffer #(
    parameter type req_t  = sramx_req_t,
    parameter type resp_t = sramx_resp_t
) (
    input logic clk, resetn,

    input  req_t  m_req,
    output resp_t m_resp,
    output req_t  s_req,
    input  resp_t s_resp
);
    logic avail;
    req_t buf_req;

    assign s_req = avail ? m_req : buf_req;

    always_comb begin
        m_resp         = s_resp;
        m_resp.addr_ok = avail;
    end

    always_ff @(posedge clk)
    if (resetn) begin
        if (s_resp.addr_ok)
            avail <= 1;
        else if (m_req.req && avail) begin
            avail   <= 0;
            buf_req <= m_req;
        end
    end else
        avail <= 1;
endmodule