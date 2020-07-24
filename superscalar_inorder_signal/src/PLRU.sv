module PLRU #(
    parameter int NUM_WAYS = 8,

    localparam int IDX_BITS    = $clog2(NUM_WAYS),
    localparam int NUM_SELECT  = NUM_WAYS - 1,

    localparam type idx_t    = logic [IDX_BITS - 1:0],
    localparam type select_t = logic [NUM_SELECT - 1:0]
) (
    input  select_t select,
    output idx_t    idx,
    output select_t new_select
);
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
        parameter int lo = 2**i;
        parameter int hi = 2 * lo - 1;
        assign idx[IDX_BITS - i - 1] = |bits[hi:lo];
    end

    // update select
    assign new_select = mask ^ select;
endmodule