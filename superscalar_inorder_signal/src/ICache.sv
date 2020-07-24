`include "icache.svh"
`include "instr_bus.svh"
`include "cache_bus.svh"

module ICache(
    input logic clk, resetn,

    input  addr_t      ibus_req_vaddr,
    input  ibus_req_t  ibus_req,
    output ibus_resp_t ibus_resp,
    output cbus_req_t  cbus_req,
    input  cbus_resp_t cbus_resp
);
    // address parsing
    icache_addr_t req_vaddr, req_paddr;
    assign req_vaddr = ibus_req_vaddr;
    assign req_paddr = ibus_req.addr;

    // set info storage
    icache_set_t [ICACHE_NUM_SETS - 1:0] sets;
    icache_set_t cur_set;
    assign cur_set = sets[req_vaddr.index];

    icache_idx_t req_idx;
    always_comb begin
        req_idx = 0;
        for (int i = 0; i < ICACHE_NUM_WAYS; i++) begin
            req_idx |= req_paddr.tag == cur_set.lines[i].tag ?
                icache_idx_t'(i) : 0;
        end
    end

    always_ff @(posedge clk)
    if (resetn) begin
    end else begin
        for (int i = 0; i < ICACHE_NUM_SETS; i++) begin
            sets[i].select <= 0;
            for (int j = 0; j < ICACHE_NUM_WAYS; j++) begin
                sets[i].lines[j].valid <= 0;
            end
        end
    end
endmodule