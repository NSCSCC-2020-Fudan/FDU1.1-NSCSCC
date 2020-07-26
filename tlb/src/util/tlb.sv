`include "tlb_bus.svh"

module tlb (
    input   logic           clk,
    input   logic           rst,
`ifdef SPLIT_MODE
    input   tlb_virt_t      inst_vaddr,
    input   tlb_virt_t      data_vaddr,
    output  tlb_result_t    inst_result,
    output  tlb_result_t    data_result,
`else
    input   tlb_virt_t      virt_addr,
    output  tlb_result_t    result,
`endif
    input   tlb_asid_t      asid,

    // for TLBP
    input   word_t          tlbp_entry_hi,
    output  word_t          tlbp_index
);

`ifdef SPLIT_MODE
    tlb_entry_t [TLB_ENTRIES_NUM-1:0] inst_entries;
    tlb_entry_t [TLB_ENTRIES_NUM-1:0] data_entries;
`else
    tlb_entry_t [TLB_ENTRIES_NUM-1:0] entries;
`endif

    genvar i;
    generate;
        for (i = 0; i < TLB_ENTRIES_NUM; i = i + 1) begin: tlb_entries
            always_ff @ (posedge clk) begin
                if (rst) begin
                    entries[i] <= '0;
                end else begin
                    // if () write to entry
                end
            end
        end
    endgenerate

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
        .result(data_vaddr)
    );
`else
    tlb_lookup lookup (
        .entries,
        .virt_addr,
        .asid,
        .result
    );
`endif

    tlb_lookup tlbp_lookup (
        .
    )
endmodule