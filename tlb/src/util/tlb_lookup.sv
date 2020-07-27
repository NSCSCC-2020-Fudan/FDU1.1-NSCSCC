`include "tlb_bus.svh"

module tlb_lookup #(
    parameter logic DATA_TLB = 0
) (
    input   tlb_entry_t [TLB_ENTRIES_NUM-1:0]   entries,
    input   tlb_addr_t                          virt_addr,
    input   tlb_asid_t                          asid,
    output  tlb_result_t                        result
);

    logic [TLB_VPN2_BITS-1:0] vpn2;

    assign vpn2 = virt_addr[31:32-TLB_VPN2_BITS];
    
    always_comb begin
        result.index.p = 1;
        for (int i = 0; i < TLB_ENTRIES_NUM; i++) begin
            if (((entries[i].compsec.vpn2 & {{(TLB_VPN2_BITS-TLB_MASK_BITS){1'b1}}, ~entries[i].compsec.pagemask}) == 
                (vpn2 & {{(TLB_VPN2_BITS-TLB_MASK_BITS){1'b1}}, ~entries[i].compsec.pagemask})) &&
                (entries[i].compsec.g || entries[i].compsec.asid == asid)) begin
                case (entries[i].compsec.pagemask)
                    16'b00_00_00_00_00_00_00_00: begin
                        result.transec = entries[i].transec[vpn2[12-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:0], virt_addr[11:0]};
                    end 
                    16'b00_00_00_00_00_00_00_11: begin
                        result.transec = entries[i].transec[vpn2[14-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:2], virt_addr[13:0]};
                    end 
                    16'b00_00_00_00_00_00_11_11: begin
                        result.transec = entries[i].transec[vpn2[16-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:4], virt_addr[15:0]};
                    end 
                    16'b00_00_00_00_00_11_11_11: begin
                        result.transec = entries[i].transec[vpn2[18-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:6], virt_addr[17:0]};
                    end 
                    16'b00_00_00_00_11_11_11_11: begin
                        result.transec = entries[i].transec[vpn2[20-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:8], virt_addr[19:0]};
                    end 
                    16'b00_00_00_11_11_11_11_11: begin
                        result.transec = entries[i].transec[vpn2[22-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:10], virt_addr[21:0]};
                    end 
                    16'b00_00_11_11_11_11_11_11: begin
                        result.transec = entries[i].transec[vpn2[24-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:12], virt_addr[23:0]};
                    end 
                    16'b00_11_11_11_11_11_11_11: begin
                        result.transec = entries[i].transec[vpn2[26-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:14], virt_addr[25:0]};
                    end 
                    16'b11_11_11_11_11_11_11_11: begin
                        result.transec = entries[i].transec[vpn2[28-TLB_OFFSET_BITS]];
                        result.phys_addr = {result.transec.pfn[19:16], virt_addr[27:0]};
                    end 
                endcase
                
                // if (!result.v) begin
                //     SignalException(TLBInvalid, reftype);
                // end else if (!result.d && reftype == store) begin
                //     SignalException(TLBModified);
                // end
                {result.index.p, result.index.idx} = {1'b0, i};
            `ifdef SPLIT_MODE
                if (DATA_TLB == 1) begin
                    result.index.idx[TLB_INDEX_BITS-1] = 1'b1;
                end
            `endif
            end
        end
        // if (!found) begin
        //     SignalException(TLBMiss, reftype);
        // end
    end
endmodule