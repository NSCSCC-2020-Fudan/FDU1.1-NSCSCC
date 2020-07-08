`include "mips.svh"

module regfile (
    input logic clk, reset,
    input creg_addr_t ra1, ra2,
    output word_t src1, src2,
    input rf_w_t w
);
    word_t [31:0] R;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            R <= '0;
        end else if(w.wen && (w.addr != '0)) begin
            R[w.addr] <= w.wd;
        end
    end
    
    assign src1 = (ra1 != '0) ? R[ra1] : '0;
    assign src2 = (ra2 != '0) ? R[ra2] : '0;
endmodule