module PLRU #(
    parameter int NUM_WAYS = 8,

    localparam int IDX_BITS    = $clog2(NUM_WAYS),
    localparam int NUM_SELECT  = NUM_WAYS - 1,

    localparam type idx_t    = logic [IDX_BITS - 1:0],
    localparam type select_t = logic [NUM_SELECT - 1:0]
) (
    input  select_t select,
    output idx_t    victim_idx,
    input  idx_t    idx,
    output select_t new_select
);
    /**
     * select idx for replacement
     */
    typedef logic [NUM_SELECT:1] mask_t;
    mask_t s, bits;
    mask_t mask /* verilator split_var */;

    // mask tree root
    assign mask[1] = 1;

    // propagation to leaves
    assign s = select;
    for (genvar i = 1; i < NUM_WAYS / 2; i++) begin: plru_mask
        assign mask[2 * i    ] = mask[i] && !s[i];
        assign mask[2 * i + 1] = mask[i] &&  s[i];
    end

    // generate idx
    assign bits = s & mask;
    for (genvar i = 0; i < IDX_BITS; i++) begin: plru_idx
        localparam int hi = 2 * lo - 1;
        localparam int lo = 2**i;
        assign victim_idx[IDX_BITS - i - 1] = |bits[hi:lo];
    end

    /**
     * calculate new select vector
     */
    mask_t rax;
    assign new_select = rax;

    assign rax[1] = ~idx[IDX_BITS - 1];
    for (genvar i = 2; i <= NUM_SELECT; i++) begin: calc_new_select
        localparam int n = $clog2(i + 1) - 1;  // number of bits from idx
        localparam int t = IDX_BITS - n - 1;   // target bit index

        idx_t v;
        assign v = {{(IDX_BITS - n - 1){1'b0}}, 1'b1, idx[IDX_BITS - 1 -: n]};
        assign rax[i] = (i == v) ? ~idx[t] : s[i];
    end
endmodule