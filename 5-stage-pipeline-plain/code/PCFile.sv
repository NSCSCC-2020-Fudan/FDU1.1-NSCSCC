`include "MIPS.svh"

module PCFile(
        input logic clk, stall, reset,
        input logic [31: 0] PCIn,
        output logic [31: 0] PCOut
    );

    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                PCOut = 32'b0;
            else
                if (!stall) 
                    PCOut = PCIn;
        end

endmodule