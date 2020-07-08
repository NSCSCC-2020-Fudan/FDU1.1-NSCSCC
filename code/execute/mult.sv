`include "mips.svh"

module mult (
    input word_t a, b,
    input decoded_op_t op,
    output word_t hi, lo
);
    dword_t ans;
    always_comb begin
        case (op)
            MULTU: begin
                ans = {32'b0, a} * {32'b0, b};
                hi = ans[63:32];
                lo = ans[31:0];
            end
            MULT: begin
                ans = {{32{a[31]}}, a} * {{32{b[31]}}, b};
                hi = ans[63:32];
                lo = ans[31:0];
            end
            DIVU: begin
                ans = '0;
                hi = {1'b0, a} / {1'b0, b};
                lo = {1'b0, a} % {1'b0, b};
            end
            DIV: begin
                ans = '0;
                hi = a / b;
                lo = a % b;
            end
            default: begin
                hi = '0;
                lo = '0;
                ans = '0;
            end
        endcase
    end
endmodule