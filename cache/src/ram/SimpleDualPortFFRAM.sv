/**
 * RAM with full reset support
 *
 * it's likely implemented in flip-flops.
 */
module SimpleDualPortFFRAM #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 10,

    localparam int MEM_NUM_WORDS = 2**ADDR_WIDTH,
    localparam int MEM_NUM_BITS  = MEM_NUM_WORDS * DATA_WIDTH,

    localparam type addr_t = logic [ADDR_WIDTH - 1:0],
    localparam type word_t = logic [DATA_WIDTH - 1:0]
) (
    input  logic clk, resetn, write_en,
    input  addr_t raddr, waddr,
    input  word_t data_in,
    output word_t data_out
);
    word_t [MEM_NUM_WORDS - 1:0] mem;
    assign data_out = mem[raddr];

    always_ff @(posedge clk)
    if (resetn) begin
        if (write_en) begin
            for (int i = 0; i < MEM_NUM_WORDS; i++) begin
                mem[i] <= waddr == addr_t'(i) ? data_in : mem[i];
            end
        end else
            mem <= mem;
    end else begin
        mem <= 0;
    end
endmodule