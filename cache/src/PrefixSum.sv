
/**
 * NOTE: be careful about endianness
 *
 * although it's named "PrefixSum", it was intended to calculate
 * suffix sums.
 */
module PrefixSum #(
    parameter int ARRAY_LENGTH = 8,

    // verilator lint_off LITENDIAN
    localparam type array_t = logic [1:ARRAY_LENGTH]
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
                partial[i] &= partial[j];
            end
        end
    end

    always_comb begin
        sum = partial;
        for (int i = 1; i <= ARRAY_LENGTH; i++) begin
            for (int j = prev(i); j > 0; j = prev(j)) begin
                sum[i] &= partial[j];
            end
        end
    end
endmodule