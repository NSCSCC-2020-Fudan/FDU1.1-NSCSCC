`include "data_bus.svh"

/**
 * to include vaddr in buffer requests
 */
module CacheBuffer #(
    parameter type req_t  = dbus_req_t,
    parameter type resp_t = dbus_resp_t
) (
    input logic clk, resetn,

    input  addr_t m_req_vaddr,
    input  req_t  m_req,
    output resp_t m_resp,
    output addr_t s_req_vaddr,
    output req_t  s_req,
    input  resp_t s_resp
);
    typedef struct packed {
        logic  req;
        addr_t vaddr;
        req_t  payload;
    } buf_req_t;

    buf_req_t i_req, o_req;

    assign i_req.req     = m_req.valid;
    assign i_req.vaddr   = m_req_vaddr;
    assign i_req.payload = m_req;

    assign s_req       = o_req.payload;
    assign s_req_vaddr = o_req.vaddr;

    RequestBuffer #(
        .req_t(buf_req_t),
        .resp_t(resp_t)
    ) req_buf_inst(
        .clk, .resetn,
        .m_req(i_req), .m_resp,
        .s_req(o_req), .s_resp
    );

    logic __unused_ok = &{1'b0, o_req.req, 1'b0};
endmodule