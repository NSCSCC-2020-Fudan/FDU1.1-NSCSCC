`include "tu.svh"
`include "tu_addr.svh"
`include "sramx.svh"
`include "instr_bus.svh"

/**
 * we didn't distinguish cached/uncached accesses in icache
 * redirecting, as they did in NonTrivialMIPS.
 */
module MMU #(
    parameter logic USE_IBUS = 1
) (
    input logic aclk, aresetn,

    input  tu_op_req_t  tu_op_req,
    output tu_op_resp_t tu_op_resp,

    input  sramx_req_t  imem_sramx_req,
    output sramx_resp_t imem_sramx_resp,
    input  ibus_req_t   imem_ibus_req,
    output ibus_resp_t  imem_ibus_resp,
    input  sramx_req_t  dmem_req,
    output sramx_resp_t dmem_resp,

    output sramx_req_t  isramx_req,
    input  sramx_resp_t isramx_resp,
    output ibus_req_t   ibus_req,
    input  ibus_resp_t  ibus_resp,
    output sramx_req_t  dcache_req,
    input  sramx_resp_t dcache_resp,
    output sramx_req_t  uncached_req,
    input  sramx_resp_t uncached_resp
);
    // address translation
    tu_addr_req_t  i_req,  d_req;
    tu_addr_resp_t i_resp, d_resp;

    if (USE_IBUS == 1) begin: with_ibus
        assign i_req.req   = imem_ibus_req.req;
        assign i_req.vaddr = imem_ibus_req.addr;

        always_comb begin
            ibus_req       = imem_ibus_req;
            ibus_req.addr  = i_resp.paddr;
            imem_ibus_resp = ibus_resp;
        end
    end else begin: without_ibus
        assign i_req.req   = imem_sramx_req.req;
        assign i_req.vaddr = imem_sramx_req.addr;

        always_comb begin
            isramx_req      = imem_sramx_req;
            isramx_req.addr = i_resp.paddr;
            imem_sramx_resp = isramx_resp;
        end
    end

    assign d_req.req   = dmem_req.req;
    assign d_req.vaddr = dmem_req.addr;

    TranslationUnit tu_inst(
        .clk(aclk), .resetn(aresetn),
        .i_req, .i_resp, .d_req, .d_resp,
        .op_req(tu_op_req),
        .op_resp(tu_op_resp)
    );

    // dispatch dcache/uncached accesses
    // NOTE: two stage pipeline here
    // split variables
    logic        dmem_addr_ok;
    logic        dmem_data_ok;
    sramx_word_t dmem_rdata;

    assign dmem_resp.addr_ok = dmem_addr_ok;
    assign dmem_resp.data_ok = dmem_data_ok;
    assign dmem_resp.rdata   = dmem_rdata;

    // registers
    logic cur_finished;     // stage 1 "addr_ok" has been received?
    logic last_finished;    // stage 2 "data_ok" has been received?
    logic last_d_uncached;  // stage 2 is uncached?

    // wires
    logic real_addr_ok;  // real "addr_ok" in stage 1
    logic cur_ready;     // can stage 1 step into stage 2?
    logic last_ready;    // stage 2 ok in current clock cycle?

    assign real_addr_ok = d_resp.is_uncached ? uncached_resp.addr_ok : dcache_resp.addr_ok;
    assign cur_ready    = last_ready && (cur_finished || real_addr_ok);
    assign last_ready   = last_finished || dmem_data_ok;

    assign dmem_addr_ok = cur_ready;

    always_comb begin
        dcache_req = 0;
        uncached_req = 0;
        // dmem_resp = 0;

        // AND with "!cur_finished": in case CPU does not deassert "req".
        if (d_resp.is_uncached) begin
            uncached_req      = dmem_req;
            uncached_req.req  = dmem_req.req && !cur_finished;
            uncached_req.addr = d_resp.paddr;
        end else begin
            dcache_req      = dmem_req;
            dcache_req.req  = dmem_req.req && !cur_finished;
            dcache_req.addr = d_resp.paddr;
        end

        if (last_d_uncached) begin
            dmem_data_ok = uncached_resp.data_ok;
            dmem_rdata   = uncached_resp.rdata;
        end else begin
            dmem_data_ok = dcache_resp.data_ok;
            dmem_rdata   = dcache_resp.rdata;
        end
    end

    always_ff @(posedge aclk)
    if (aresetn) begin
        if (dmem_req.req) begin
            if (cur_ready) begin
                cur_finished    <= 0;
                last_finished   <= 0;
                last_d_uncached <= d_resp.is_uncached;
            end else if (!cur_finished)
                cur_finished <= real_addr_ok;
        end

        if (!last_finished)
            last_finished <= dmem_resp.data_ok;
    end else begin
        cur_finished    <= 0;
        last_finished   <= 1;
        last_d_uncached <= 0;
    end

    /**
     * unused
     */
    if (USE_IBUS == 1) begin
        assign imem_sramx_resp = 0;
        assign isramx_req      = 0;

        logic __unused_ok = &{1'b0,
            i_resp.is_uncached, imem_sramx_req, isramx_resp,
        1'b0};
    end else begin
        assign imem_ibus_resp = 0;
        assign ibus_req       = 0;

        logic __unused_ok = &{1'b0,
            i_resp.is_uncached, imem_ibus_req, ibus_resp,
        1'b0};
    end
endmodule