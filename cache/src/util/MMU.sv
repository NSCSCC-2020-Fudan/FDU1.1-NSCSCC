`include "sramx.svh"
`include "instr_bus.svh"

/**
 * we didn't distinguish cached/uncached accesses in icache
 * redirecting, as they did in NonTrivialMIPS.
 */
module MMU #(
    parameter logic USE_IBUS = 0
) (
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
    addr_t iaddr, daddr;
    logic i_uncached, d_uncached;

    DirectMappedAddr _d_map_inst(
        .vaddr(dmem_req.addr),
        .paddr(daddr), .is_uncached(d_uncached)
    );

    // directly pass imem requests
    if (USE_IBUS == 1) begin: with_ibus
        DirectMappedAddr _i_map_inst(
            .vaddr(imem_ibus_req.addr),
            .paddr(iaddr), .is_uncached(i_uncached)
        );

        always_comb begin
            ibus_req       = imem_ibus_req;
            ibus_req.addr  = iaddr;
            imem_ibus_resp = ibus_resp;
        end
    end else begin: without_ibus
        DirectMappedAddr _i_map_inst(
            .vaddr(imem_sramx_req.addr),
            .paddr(iaddr), .is_uncached(i_uncached)
        );

        always_comb begin
            isramx_req      = imem_sramx_req;
            isramx_req.addr = iaddr;
            imem_sramx_resp = isramx_resp;
        end
    end

    // dispatch dcache/uncached accesses
    always_comb begin
        dcache_req = 0;
        uncached_req = 0;
        dmem_resp = 0;

        if (d_uncached) begin
            uncached_req = dmem_req;
            uncached_req.addr = daddr;
            dmem_resp = uncached_resp;
        end else begin
            dcache_req = dmem_req;
            dcache_req.addr = daddr;
            dmem_resp = dcache_resp;
        end
    end

    if (USE_IBUS == 1) begin
        assign imem_sramx_resp = 0;
        assign isramx_req      = 0;

        logic __unused_ok = &{1'b0,
            i_uncached, imem_sramx_req, isramx_resp,
        1'b0};
    end else begin
        assign imem_ibus_resp = 0;
        assign ibus_req       = 0;

        logic __unused_ok = &{1'b0,
            i_uncached, imem_ibus_req, ibus_resp,
        1'b0};
    end
endmodule