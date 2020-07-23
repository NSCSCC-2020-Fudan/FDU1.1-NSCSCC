
/**
 * NOTE: be careful about endianness
 *
 * although it's named "PrefixSum", it was intended to calculate
 * suffix sums.
 */
module PrefixSum #(
    parameter int ARRAY_LENGTH = 8,

    localparam type array_t = logic [ARRAY_LENGTH - 1:0]
) (
    input array_t arr,
    output array_t sum
);
    array_t partial;

    function int lowbit(input int x);
        return x & (-x);
    endfunction

    function int prev(input int x);
        return x - lowbit(x);
    endfunction

    always_comb begin
        partial = arr;
        for (int i = 1; i <= ARRAY_LENGTH; i++) begin
            for (int j = i - 1; j > 0; j = prev(j)) begin
                partial[ARRAY_LENGTH - i] &= partial[ARRAY_LENGTH - j];
            end
        end
    end

    always_comb begin
        sum = partial;
        for (int i = 1; i <= ARRAY_LENGTH; i++) begin
            for (int j = prev(i); j > 0; j = prev(j)) begin
                sum[ARRAY_LENGTH - i] &= partial[ARRAY_LENGTH - j];
            end
        end
    end
endmodule