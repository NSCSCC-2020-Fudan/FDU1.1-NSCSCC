`include "tu.svh"
`include "tu_addr.svh"
`include "instr_bus.svh"
`include "data_bus.svh"

/**
 * we didn't distinguish cached/uncached accesses in icache
 * redirecting, as they did in NonTrivialMIPS.
 */
module MMU(
    input logic clk, resetn,

    input  tu_op_req_t  tu_op_req,
    output tu_op_resp_t tu_op_resp,

    input  ibus_req_t  imem_req,
    output ibus_resp_t imem_resp,
    input  dbus_req_t  dmem_req,
    output dbus_resp_t dmem_resp,

    output ibus_req_t  icache_req,
    input  ibus_resp_t icache_resp,
    output dbus_req_t  dcache_req,
    input  dbus_resp_t dcache_resp,
    output dbus_req_t  uncached_req,
    input  dbus_resp_t uncached_resp,
    input logic k0_uncached
);
    // address translation
    tu_addr_req_t  i_req,  d_req;
    tu_addr_resp_t i_resp, d_resp;

    assign i_req.req = imem_req.req;
    assign i_req.vaddr = imem_req.addr;
    assign imem_resp   = icache_resp;

    always_comb begin
        icache_req      = imem_req;
        icache_req.addr = i_resp.paddr;
    end

    assign d_req.req   = dmem_req.req;
    assign d_req.vaddr = dmem_req.addr;

    TranslationUnit tu_inst(
        .clk(clk), .resetn(resetn),
        .i_req, .i_resp, .d_req, .d_resp,
        .op_req(tu_op_req),
        .op_resp(tu_op_resp),
        .k0_uncached
    );

    // dispatch dcache/uncached accesses
    // NOTE: two stage pipeline here
    // split variables
    logic       dmem_addr_ok;
    logic       dmem_data_ok;
    dbus_word_t dmem_rdata;

    assign dmem_resp.addr_ok = dmem_addr_ok;
    assign dmem_resp.data_ok = dmem_data_ok;
    assign dmem_resp.data    = dmem_rdata;

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
            dmem_rdata   = uncached_resp.data;
        end else begin
            dmem_data_ok = dcache_resp.data_ok;
            dmem_rdata   = dcache_resp.data;
        end
    end

    always_ff @(posedge clk)
    if (resetn) begin
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
    logic __unused_ok = &{1'b0,
        i_resp.is_uncached,
    1'b0};
endmodule