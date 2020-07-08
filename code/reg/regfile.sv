`include "mips.svh"

module regfile_ (
    input logic clk, reset,
    // input creg_addr_t ra1, ra2,
    // output word_t src1, src2,
    // input rf_w_t w
    regfile_intf.regfile ports
);
    word_t [31:0] R;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            R <= '0;
        end else if(ports.rfwrite.wen && (ports.rfwrite.addr != '0)) begin
            R[ports.rfwrite.addr] <= ports.rfwrite.wd;
        end
    end
    
    assign ports.src1 = (ports.ra1 != '0) ? R[ports.ra1] : '0;
    assign ports.src2 = (ports.ra2 != '0) ? R[ports.ra2] : '0;
endmodule