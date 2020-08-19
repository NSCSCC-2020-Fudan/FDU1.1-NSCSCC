`include "mips.svh"

module dreg(
        input logic clk, reset,
        input logic stallD, flushD,
        input fetch_data_t [1: 0] in,
        output fetch_data_t [1: 0] out,
        input logic [1: 0] hitF,
        output logic [1: 0] hitD,
        input logic wait_ex
    );
    
    always_ff @(posedge clk)
        begin
            if (~reset)
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
                    begin
                        if (~stallD)
                            begin
                                out <= in;
                                hitD <= hitF;
                            end
                        else
                            out <= out;
                    end
        end
endmodule

module creg(
        input logic clk, reset,
        input logic stallC, flushC,
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out,
        output logic first_cycleC,
        input logic [5: 0] ext_int_in,
        output logic [5: 0] ext_int_out,
        input logic timer_interrupt_in,
        output logic timer_interrupt_out,
        input logic wait_ex
    );
    
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    out <= '0;
                    first_cycleC <= '1;
                    ext_int_out <= '0;
                    timer_interrupt_out <= '0;
                end
            else
                if (flushC)
                    begin
                        out <= '0;
                        first_cycleC <= '1;
                        ext_int_out <= '0;
                        timer_interrupt_out <= '0;
                    end 
                else
                    begin
                        if (~stallC)
                            begin
                                out <= in;
                                first_cycleC <= '1;
                                ext_int_out <= ext_int_in;
                                timer_interrupt_out <= timer_interrupt_in;
                            end
                        else
                            begin
                                out <= out;
                                first_cycleC <= '0;
                                ext_int_out <= (wait_ex) ? (ext_int_in) : (ext_int_out);
                                timer_interrupt_out <= (wait_ex) ? (timer_interrupt_in) : (timer_interrupt_out);
                            end
                    end                                                
        end
endmodule

module rreg(
        input logic clk, reset,
        input logic stallR, flushR,
        input exec_data_t [1: 0] in,
        output exec_data_t [1: 0] out
    );
    
    always_ff @(posedge clk)
        begin
            if (~reset) 
                out <= '0;
            else
                if (flushR)
                    out <= '0;
                else
                    begin
                        if (~stallR) 
                            out <= in;
                        else
                            out <= out;
                    end                            
        end
endmodule