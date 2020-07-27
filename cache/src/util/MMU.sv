`include "sramx.svh"
`include "instr_bus.svh"
`include "tlb_bus.svh"
`include "mmu_bus.svh"

/**
 * we didn't distinguish cached/uncached accesses in icache
 * redirecting, as they did in NonTrivialMIPS.
 */
module MMU #(
    parameter logic USE_IBUS = 0,
    parameter logic CPU_TLB_ENABLED = 1
) (
    // for TLB
    input   logic           aclk, aresetn,
    input   tlb_addr_t      inst_addr,    data_addr,
    input   tlb_asid_t      asid,
    output  mmu_result_t    inst_mmu_result, data_mmu_result,

    // for TLBWI, TLBR, TLBWR
    input   tlb_index_t     tlb_index,
    input   logic           tlb_we,
    input   tlb_entry_t     tlb_wdata,
    output  tlb_entry_t     tlb_rdata,

    // for TLBP
    input   tlb_entryhi_t   tlbp_entryhi,
    output  tlb_index_t     tlbp_index,

    input  sramx_req_t      imem_sramx_req,
    output sramx_resp_t     imem_sramx_resp,
    input  ibus_req_t       imem_ibus_req,
    output ibus_resp_t      imem_ibus_resp,
    input  sramx_req_t      dmem_req,
    output sramx_resp_t     dmem_resp,

    output sramx_req_t      isramx_req,
    input  sramx_resp_t     isramx_resp,
    output ibus_req_t       ibus_req,
    input  ibus_resp_t      ibus_resp,

    output sramx_req_t      dcache_req,
    input  sramx_resp_t     dcache_resp,
    output sramx_req_t      uncached_req,
    input  sramx_resp_t     uncached_resp
);
    // address translation
    addr_t iaddr, daddr;
    logic i_uncached, d_uncached;
    logic inst_mapped, data_mapped;

    function logic is_vaddr_mapped(
        input tlb_addr_t virt_addr
    );
        return (~virt_addr[31] || virt_addr[31:30] == 2'b11);
    endfunction

    DirectMappedAddr _d_map_inst(
        .vaddr(dmem_req.addr),
        .paddr(daddr), .is_uncached(d_uncached)
    );

    generate
        if(CPU_TLB_ENABLED) begin: generate_tlb_enabled_code
            
            tlb_result_t inst_tlb_result, data_tlb_result;

            assign inst_mapped = is_vaddr_mapped(inst_addr);
            assign data_mapped = is_vaddr_mapped(data_addr);

            assign inst_mmu_result.invalid = inst_mapped & ~inst_tlb_result.transec.v;
            assign inst_mmu_result.modified = inst_tlb_result.transec.d;
            assign inst_mmu_result.miss = inst_mapped & inst_tlb_result.index.p;
            assign inst_mmu_result.phys_addr = inst_tlb_result.phys_addr;
            assign inst_mmu_result.virt_addr = inst_addr;

            assign data_mmu_result.invalid = data_mapped & ~data_tlb_result.transec.v;
            assign data_mmu_result.modified = data_tlb_result.transec.d;
            assign data_mmu_result.miss = data_mapped & data_tlb_result.index.p;
            assign data_mmu_result.phys_addr = data_tlb_result.phys_addr;
            assign data_mmu_result.virt_addr = data_addr;

            TLB L1TLB (
                .clk(aclk),
                .rst(aresetn),
                .inst_vaddr(inst_addr),
                .inst_result(inst_tlb_result),
                .data_vaddr(data_addr),
                .data_result(data_tlb_result),
                .asid,
                
                .tlb_index,
                .tlb_we,
                .tlb_wdata,
                .tlb_rdata,

                .tlbp_entryhi,
                .tlbp_index
            );
        end
    endgenerate

    // directly pass imem requests
    if (USE_IBUS == 1) begin: with_ibus
        DirectMappedAddr _i_map_inst(
            .vaddr(imem_ibus_req.addr),
            .paddr(iaddr), .is_uncached(i_uncached)
        );

        always_comb begin
            ibus_req       = imem_ibus_req;
            ibus_req.addr  = inst_mapped ? inst_mmu_result.phys_addr : iaddr;
            imem_ibus_resp = ibus_resp;
        end
    end else begin: without_ibus
        DirectMappedAddr _i_map_inst(
            .vaddr(imem_sramx_req.addr),
            .paddr(iaddr), .is_uncached(i_uncached)
        );

        always_comb begin
            isramx_req      = imem_sramx_req;
            isramx_req.addr = inst_mapped ? inst_mmu_result.phys_addr : iaddr;
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
            uncached_req.addr = data_mapped ? data_mmu_result.phys_addr : daddr;
            dmem_resp = uncached_resp;
        end else begin
            dcache_req = dmem_req;
            dcache_req.addr = data_mapped ? data_mmu_result.phys_addr : daddr;
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