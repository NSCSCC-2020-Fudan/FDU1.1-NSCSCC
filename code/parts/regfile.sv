`include "../mips.svh"

module regfile (
    rf_intf.rf io
);
    word_t [31:0] R;
    always_ff @(negedge io.clk, posedge io.reset) begin
        if (io.reset) begin
            R <= '0;
        end else if(io.w.en && (io.w.addr != '0)) begin
            R[io.w.addr] <= io.w.wd;
        end
    end

    assign io.src1 = (io.ra1 != '0) ? R[io.ra1] : '0;
    assign io.src2 = (io.ra2 != '0) ? R[io.ra2] : '0;
endmodule