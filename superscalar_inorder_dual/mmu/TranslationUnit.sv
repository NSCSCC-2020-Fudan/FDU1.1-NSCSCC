`ifndef DISABLE_DEFAULT_TU

`include "mips.svh"
`include "tu.svh"
`include "tu_addr.svh"

module TranslationUnit(
    input logic clk, resetn,

    // address translation requests
    input logic k0_uncached,
    input  tu_addr_req_t  i_req,  d_req,
    output tu_addr_resp_t i_resp, d_resp,

    // TU interactions
    input  tu_op_req_t  op_req,
    output tu_op_resp_t op_resp
);

    logic i_mapped, d_mapped;
    logic i_invalid, d_invalid;
    logic i_dirty, d_dirty;
    logic i_hit, d_hit;
    assign i_mapped = ~i_req.vaddr[31] || (i_req.vaddr[31:30] == 2'b11);
    assign d_mapped = ~d_req.vaddr[31] || (d_req.vaddr[31:30] == 2'b11);
    word_t inst_paddr_tlb, data_paddr_tlb, inst_paddr_direct, data_paddr_direct;
    assign i_resp.paddr = i_mapped ? inst_paddr_tlb : inst_paddr_direct;
    assign d_resp.paddr = d_mapped ? data_paddr_tlb : data_paddr_direct;
    assign op_resp.i_tlb_invalid = i_mapped & i_invalid;
    assign op_resp.i_tlb_modified = i_mapped & ~i_invalid & ~i_dirty;
    assign op_resp.d_tlb_invalid = d_mapped & d_invalid;
    assign op_resp.d_tlb_modified = d_mapped & ~d_invalid & ~d_dirty;
    assign op_resp.i_tlb_refill = i_mapped & ~i_hit;
    assign op_resp.d_tlb_refill = d_mapped & ~d_hit;
    DirectMappedAddr i_map_inst(
        .vaddr(i_req.vaddr),
        .paddr(inst_paddr_direct),
        .is_uncached(i_resp.is_uncached),
        .k0_uncached
    );
    logic d_uncached;
    DirectMappedAddr d_map_inst(
        .vaddr(d_req.vaddr),
        .paddr(data_paddr_direct),
        .is_uncached(d_uncached),
        .k0_uncached
    );
    logic[2:0] d_cache_flag;
    assign d_resp.is_uncached = d_uncached || (d_mapped && d_cache_flag == 3'd2);
    tlbwrite_t tlbw;
    assign tlbw.valid = op_req.is_tlbwi;
    assign tlbw.addr = op_req.index.index;
    assign tlbw.data.vpn2 = op_req.entryhi.vpn2;
    assign tlbw.data.asid = op_req.entryhi.asid;
    assign tlbw.data.G = op_req.entrylo0.G & op_req.entrylo1.G;
    assign tlbw.data.pfn0 = op_req.entrylo0.pfn;
    assign tlbw.data.pfn1 = op_req.entrylo1.pfn;
    assign tlbw.data.C0 = op_req.entrylo0.C;
    assign tlbw.data.C1 = op_req.entrylo1.C;
    assign tlbw.data.V0 = op_req.entrylo0.V;
    assign tlbw.data.V1 = op_req.entrylo1.V;
    assign tlbw.data.D0 = op_req.entrylo0.D;
    assign tlbw.data.D1 = op_req.entrylo1.D;

    tlb_entry_t tlbrd;
    assign op_resp.entryhi.vpn2 = tlbrd.vpn2;
    assign op_resp.entryhi.zero = '0;
    assign op_resp.entryhi.asid = tlbrd.asid;
    assign op_resp.entrylo0.fill = '0;
    assign op_resp.entrylo0.pfn = tlbrd.pfn0;
    assign op_resp.entrylo0.C = tlbrd.C0;
    assign op_resp.entrylo0.D = tlbrd.D0;
    assign op_resp.entrylo0.V = tlbrd.V0;
    assign op_resp.entrylo0.G = tlbrd.G;
    assign op_resp.entrylo1.fill = '0;
    assign op_resp.entrylo1.pfn = tlbrd.pfn1;
    assign op_resp.entrylo1.C = tlbrd.C1;
    assign op_resp.entrylo1.D = tlbrd.D1;
    assign op_resp.entrylo1.V = tlbrd.V1;
    assign op_resp.entrylo1.G = tlbrd.G;
    
    tlb tlb(
        .clk, .resetn,
        .tlbw,
        .tlbra(op_req.index.index),
        .tlbrd,
        .asid(op_req.entryhi.asid),
        .inst_vaddr(i_req.vaddr),
        .data_vaddr(d_req.vaddr),
        .inst_paddr_tlb,
        .data_paddr_tlb,
        .i_invalid, .d_invalid,
        .i_dirty, .d_dirty,
        .i_hit, .d_hit,
        .d_cache_flag,
        .entryhi(op_req.entryhi),
        .index(op_resp.index)
    );
    // assign op_resp = 0;
    logic __unused_ok = &{1'b0, clk, resetn, op_req, 1'b0};
endmodule

module tlb (
    input logic clk, resetn,
    input tlbwrite_t tlbw,
    input tlb_addr_t tlbra,
    output tlb_entry_t tlbrd,

    // addr
    input logic[7:0] asid,
    input word_t inst_vaddr, data_vaddr,
    output word_t inst_paddr_tlb, data_paddr_tlb,// ??
    output logic i_invalid, d_invalid, 
    output logic i_dirty, d_dirty,
    output logic i_hit, d_hit,
    output logic [2:0] d_cache_flag,
    // TLBP
    input cp0_entryhi_t entryhi,
    output cp0_index_t index
);
    tlb_table_t tlb_table;
    assign tlbrd = tlb_table[tlbra];
    for (genvar i=0; i<TLB_ENTRIES; i++) begin
        always_ff @(posedge clk) begin
            if (~resetn) begin
                tlb_table[i] <= '0;
            end else if (tlbw.valid && tlbw.addr == i) begin
                tlb_table[i] <= tlbw.data;
            end
        end
    end

    tlblut_resp_t i_resp, d_resp, tlbp_resp;
    assign inst_paddr_tlb = i_resp.paddr;
    assign data_paddr_tlb = d_resp.paddr;
    assign index.P = ~tlbp_resp.hit;
    assign index.index = tlbp_resp.tlb_addr;
    assign index.zero = '0;
    tlb_lut ilut(.tlb_table,
                 .vaddr(inst_vaddr),
                 .asid,
                 .tlblut_resp(i_resp));
    tlb_lut dlut(.tlb_table,
                 .vaddr(data_vaddr),
                 .asid,
                 .tlblut_resp(d_resp));
    tlb_lut tlbp_lut(.tlb_table,
                     .vaddr(entryhi),
                     .asid,
                     .tlblut_resp(tlbp_resp));
    
    assign i_invalid = ~i_resp.valid;
    assign d_invalid = ~d_resp.valid;
    assign i_dirty = i_resp.dirty;
    assign d_dirty = d_resp.dirty;
    assign i_hit = i_resp.hit;
    assign d_hit = d_resp.hit;
    assign d_cache_flag = d_resp.cache_flag;
endmodule

module tlb_lut (
    input tlb_table_t tlb_table,
    input word_t vaddr,
    input logic[7:0] asid,
    output tlblut_resp_t tlblut_resp
);
    logic [TLB_ENTRIES-1:0] hit_mask;
    tlb_addr_t hit_addr;

    for (genvar i=0; i<TLB_ENTRIES; i++) begin
        assign hit_mask[i] = (tlb_table[i].vpn2 == vaddr[31:13]) && 
                             (tlb_table[i].asid == asid || tlb_table[i].G); 
    end

    always_comb begin
        hit_addr = '0;
        for (int i = TLB_ENTRIES - 1; i >= 0; i--) begin
            if (hit_mask[i]) begin
                hit_addr = i;
            end
        end
    end

    assign tlblut_resp.paddr = {
        vaddr[12] ? tlb_table[hit_addr].pfn1 : tlb_table[hit_addr].pfn0,
        vaddr[11:0]
    };
    assign tlblut_resp.tlb_addr = hit_addr;
    assign tlblut_resp.hit = |hit_mask;
    assign tlblut_resp.dirty = vaddr[12] ? tlb_table[hit_addr].D1 : tlb_table[hit_addr].D0;
    assign tlblut_resp.valid = vaddr[12] ? tlb_table[hit_addr].V1 : tlb_table[hit_addr].V0;
    assign tlblut_resp.cache_flag = vaddr[12] ? tlb_table[hit_addr].C1 : tlb_table[hit_addr].C0;// ??
endmodule

`endif