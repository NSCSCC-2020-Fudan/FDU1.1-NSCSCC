`include "sramx.svh"

/**
 * we didn't distinguish cached/uncached accesses in icache
 * redirecting, as they did in NonTrivialMIPS.
 */
module MMU(
    input  sramx_req_t  imem_req,
    output sramx_resp_t imem_resp,
    input  sramx_req_t  dmem_req,
    output sramx_resp_t dmem_resp,

    output sramx_req_t  icache_req,
    input  sramx_resp_t icache_resp,
    output sramx_req_t  dcache_req,
    input  sramx_resp_t dcache_resp,
    output sramx_req_t  uncached_req,
    input  sramx_resp_t uncached_resp
);
    // address translation
    addr_t iaddr, daddr;
    logic i_uncached, d_uncached;
    DirectMappedAddr _i_map_inst(
        .vaddr(imem_req.addr),
        .paddr(iaddr), .is_uncached(i_uncached)
    );
    DirectMappedAddr _d_map_inst(
        .vaddr(dmem_req.addr),
        .paddr(daddr), .is_uncached(d_uncached)
    );

    // directly pass imem requests
    always_comb begin
        icache_req = imem_req;
        icache_req.addr = iaddr;
        imem_resp = icache_resp;
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

    logic __unused_ok = &{1'b0, i_uncached, 1'b0};
endmodule