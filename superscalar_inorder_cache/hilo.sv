`include "mips.svh"

module hilo (
        input logic clk, reset,
        input logic hiloread,
        output word_t hiW, loW,
        input hilo_w_t hlw
    );
    
    word_t hi, lo;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            hi <= '0;
            lo <= '0;
        end else begin
            if (hlw.wen_h)
                hi <= hlw.wd_h;
            else 
                hi <= hi;

            if (hlw.wen_l)
                lo <= hlw.wd_l;
            else
                lo <= lo;
        end
    end

    assign hiW = hi;
    assign loW = lo;

endmodule