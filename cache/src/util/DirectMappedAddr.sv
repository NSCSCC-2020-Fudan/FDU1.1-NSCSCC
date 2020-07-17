`include "defs.svh"

module DirectMappedAddr(
    input addr_t vaddr,
    output addr_t paddr,
    output logic is_uncached
);
    // 0x8/0x9: 1000/1001, 0xa/0xb: 1010/1011
    assign is_uncached = vaddr[BITS_PER_WORD - 3];
    assign paddr = {3'b000, vaddr[BITS_PER_WORD - 4:0]};
endmodule