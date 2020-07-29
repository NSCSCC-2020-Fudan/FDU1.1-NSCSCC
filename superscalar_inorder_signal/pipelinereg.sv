`include "mips.svh"

module dreg(
        input logic clk, reset,
        input logic stallD, flushD,
        input fetch_data_t [1: 0] in,
        output fetch_data_t [1: 0] out,
        input logic [1: 0] hitF,
        output logic [1: 0] hitD
    );
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    out <= '0;
                    hitD <= '0;
                end
            else
                if (flushD)
                    begin
                        out <= '0;
                        hitD <= '0;    
                    end
                else
                    if (~stallD)
                        begin
                            out <= in;
                            hitD <= hitF;
                        end
        end
endmodule

module creg(
        input logic clk, reset,
        input logic stallC, flushC,
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        output logic first_cycleC
    );
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    out <= '0;
                    first_cycleC <= '1;
                end
            else
                if (flushC)
                    begin
                        out <= '0;
                        first_cycleC <= '1;
                    end 
                else
                    if (~stallC)
                        begin
                            out <= in;
                            first_cycleC <= '1;
                        end
                    else
                        first_cycleC <= '0;                    
        end
endmodule

module rreg(
        input logic clk, reset,
        input logic stallR, flushR,
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out
    );
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset) 
                out <= '0;
            else
                if (flushR)
                    out <= '0;
                else
                    if (~stallR) 
                        out <= in;
                    else
                        out <= out;
        end
endmodule