`include "tlb_bus.svh"

module tlb_lookup(
    input   tlb_entry_t [TLB_ENTRIES_NUM-1:0]   entries,
    input   tlb_virt_t                          virt_addr,
    input   tlb_asid_t                          asid,
    output  tlb_result_t                        result
);

logic [5:0] EvenOddBit;

always_comb begin
    logic found = 0;
    for (genvar i = 0; i < TLB_ENTRIES_NUM; i = i + 1) begin
        if (((entries[i].compsec.vpn2 & {{(TLB_VPN2_BITS-TLB_MASK_BITS){1'b1}}, ~entries[i].compsec.pagemask}) == 
             (virt_addr[31:32-TLB_VPN2_BITS] & {{(TLB_VPN2_BITS-TLB_MASK_BITS){1'b1}}, ~entries[i].compsec.pagemask})) &&
            (entries[i].compsec.g || entries[i].compsec.asid == asid)) begin
            case (entries[i])
                16'b00_00_00_00_00_00_00_00: EvenOddBit = 12;
                16'b00_00_00_00_00_00_00_11: EvenOddBit = 14;
                16'b00_00_00_00_00_00_11_11: EvenOddBit = 16;
                16'b00_00_00_00_00_11_11_11: EvenOddBit = 18;
                16'b00_00_00_00_11_11_11_11: EvenOddBit = 20;
                16'b00_00_00_11_11_11_11_11: EvenOddBit = 22;
                16'b00_00_11_11_11_11_11_11: EvenOddBit = 24;
                16'b00_11_11_11_11_11_11_11: EvenOddBit = 26;
                16'b11_11_11_11_11_11_11_11: EvenOddBit = 28;
            endcase
            result = entries[i].transec[virt_addr[EvenOddBit]];
            // if (!result.v) begin
            //     SignalException(TLBInvalid, reftype);
            // end else if (!result.d && reftype == store) begin
            //     SignalException(TLBModified);
            // end
            found = 1;
        end
    end
    // if (!found) begin
    //     SignalException(TLBMiss, reftype);
    // end
end