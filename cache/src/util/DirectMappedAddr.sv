`include "defs.svh"

module DirectMappedAddr(
    input addr_t vaddr,
    input logic k0_uncached,
    output addr_t paddr,
    output logic is_uncached
);
    // 0x8/0x9: 1000/1001, 0xa/0xb: 1010/1011
    // assign is_uncached = vaddr[BITS_PER_WORD - 3];
    assign is_uncached = ~(vaddr[31:29] == 3'b101 || (vaddr[31:29] == 3'b100 && k0_uncached));
    // assign paddr = {3'b000, vaddr[BITS_PER_WORD - 4:0]};
    assign paddr[27:0] = vaddr[27:0];
    always_comb begin
        case (vaddr[31:28])
            4'ha : paddr[31:28] = 4'b0;
            4'hb : paddr[31:28] = 4'b1;
            4'h8 : paddr[31:28] = 4'b0;
            4'h9 : paddr[31:28] = 4'b1;
            default: begin
               paddr[31:28] = vaddr[31:28]; 
            end
        endcase
    end
endmodule