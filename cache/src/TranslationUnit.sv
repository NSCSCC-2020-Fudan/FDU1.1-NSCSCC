`ifndef DISABLE_DEFAULT_TU

`include "defs.svh"
`include "tu.svh"
`include "tu_addr.svh"

module TranslationUnit(
    input logic clk, resetn,

    // address translation requests
    input  tu_addr_req_t  i_req,  d_req,
    output tu_addr_resp_t i_resp, d_resp,

    // TU interactions
    input  tu_op_req_t  op_req,
    output tu_op_resp_t op_resp
);
    DirectMappedAddr i_map_inst(
        .vaddr(i_req.vaddr),
        .paddr(i_resp.paddr),
        .is_uncached(i_resp.is_uncached)
    );

    DirectMappedAddr d_map_inst(
        .vaddr(d_req.vaddr),
        .paddr(d_resp.paddr),
        .is_uncached(d_resp.is_uncached)
    );

    assign op_resp = 0;
    logic __unused_ok = &{1'b0, clk, resetn, op_req, 1'b0};
endmodule

`endif