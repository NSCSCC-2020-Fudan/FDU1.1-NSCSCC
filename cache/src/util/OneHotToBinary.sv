module OneHotToBinary #(
    parameter int SIZE = 8,

    localparam int IDX_BITS = $clog2(SIZE),
    localparam type vec_t = logic [SIZE - 1:0],
    localparam type idx_t = logic [IDX_BITS - 1:0]
) (
    input  vec_t vec,
    output idx_t idx
);
    always_comb begin
        idx = 0;
        for (int i = 0; i < SIZE; i++) begin
            idx |= vec[i] ? idx_t'(i) : 0;
        end
    end
endmodule