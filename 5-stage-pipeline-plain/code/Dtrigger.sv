`include "MIPS.svh"

module Dtrigger#(
    parameter WIDTH = 32
    )(
        input logic clk, stall, reset,
        input logic [WIDTH - 1: 0] a,
        output logic [WIDTH - 1: 0] b
    );
    
    always_ff @(posedge clk, posedge reset)
        if (reset)
            b = {(WIDTH - 1)1'b0};
        else 
            begin
                if (stall) 
                    b = a;
                else
                    begin
                        if (reset)
                            b = {(WIDTH - 1)1'b0};
                        else 
                            pass
                    end 
            end

endmodule