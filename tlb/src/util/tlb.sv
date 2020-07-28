`include "tlb_bus.svh"

module TLB (
    input   logic           clk,
    input   logic           rst,
`ifdef SPLIT_MODE
    input   tlb_addr_t      inst_vaddr,
    input   tlb_addr_t      data_vaddr,
    output  tlb_result_t    inst_result,
    output  tlb_result_t    data_result,
`else
    input   tlb_addr_t      virt_addr,
    output  tlb_result_t    result,
`endif
    input   tlb_asid_t      asid,

    // for TLBWI, TLBR, TLBWR
    input   tlb_index_t     tlb_index,
    input   logic           tlb_we,
    input   tlb_entry_t     tlb_wdata,
    output  tlb_entry_t     tlb_rdata,

    // for TLBP
    input   tlb_entryhi_t   tlbp_entryhi,
    output  tlb_index_t     tlbp_index
);

tlb_result_t inst_tlbp_result, data_tlbp_result;

`ifdef SPLIT_MODE
    tlb_entry_t [TLB_ENTRIES_NUM-1:0] inst_entries;
    tlb_entry_t [TLB_ENTRIES_NUM-1:0] data_entries;
`else
    tlb_entry_t [TLB_ENTRIES_NUM-1:0] entries;
`endif

`ifdef SPLIT_MODE
    tlb_lookup inst_lookup (
        .entries(inst_entries),
        .virt_addr(inst_vaddr),
        .asid,
        .result(inst_result)
    );

    tlb_lookup data_lookup (
        .entries(data_entries),
        .virt_addr(data_vaddr),
        .asid,
        .result(data_result)
    );

    tlb_lookup inst_tlbp_lookup (
        .entries(inst_entries),
        .virt_addr(tlbp_entryhi),
        .asid(tlbp_entryhi.asid),
        .result(inst_tlbp_result)
    );

    tlb_lookup data_tlbp_lookup (
        .entries(data_entries),
        .virt_addr(tlbp_entryhi),
        .asid(tlbp_entryhi.asid),
        .result(data_tlbp_result)
    );
    
    generate
        for (genvar i = 0; i < TLB_ENTRIES_NUM; i = i + 1) begin: inst_tlb_entries
            always_ff @ (posedge clk) begin
                if (rst) begin
                    inst_entries[i] <= '0;
                end else if (tlb_we && !tlb_index.idx[TLB_INDEX_BITS] && 
                            tlb_index.idx[TLB_INDEX_BITS-1:0] == i) begin
                    inst_entries[i] <= tlb_wdata;
                end
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < TLB_ENTRIES_NUM; i = i + 1) begin: data_tlb_entries
            always_ff @ (posedge clk) begin
                if (rst) begin
                    data_entries[i] <= '0;
                end else if (tlb_we && tlb_index.idx[TLB_INDEX_BITS] && 
                            tlb_index.idx[TLB_INDEX_BITS-1:0] == i) begin
                    data_entries[i] <= tlb_wdata;
                end
            end
        end
    endgenerate

    assign tlb_rdata = !tlb_index.idx[TLB_INDEX_BITS] ? 
        inst_entries[tlb_index.idx[TLB_INDEX_BITS-1:0]] : 
        data_entries[tlb_index.idx[TLB_INDEX_BITS-1:0]];

    assign tlbp_index = !inst_tlbp_result.index.p ? 
        inst_tlbp_result.index : data_tlbp_result.index;
`else
    tlb_lookup lookup (
        .entries,
        .vpn2,
        .asid,
        .result
    );

    // genvar i;
    // generate;
    //     for (i = 0; i < TLB_ENTRIES_NUM; i = i + 1) begin: tlb_entries
    //         always_ff @ (posedge clk) begin
    //             if (rst) begin
    //                 entries[i] <= '0;
    //             end else begin
    //                 // if () write to entry
    //             end
    //         end
    //     end
    // endgenerate
`endif

endmodule