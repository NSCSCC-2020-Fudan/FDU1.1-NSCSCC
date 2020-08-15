`include "mips.svh"

module MULALU(
        input clk, reset, flush,
        input mulfunc_t mulfunc, 
        input word_t hi_ina, lo_ina, 
        input word_t hi_inb, lo_inb,
        output word_t hi_out, lo_out,
        input logic multen, finish_in, 
        output logic finish_out, exception_of,
        output logic multmask 
    );
    
    logic [63: 0] a, b, c;
    logic [64: 0] temp;
    always_ff @(posedge clk)
        begin   
            if (finish_in & ~flush & reset) 
                begin
                    finish_out <= 1'b1;
                    a <= {hi_ina, lo_ina};
                    b <= {hi_inb, lo_inb};
                    multmask <= 1'b1;
                end
            else
                begin
                    finish_out <= 1'b0;
                    //a <= '0;
                    //b <= '0;
                    multmask <= 1'b0;
                end
        end
    
    always_comb begin
        exception_of = 0;
        temp = '0;
        case (mulfunc)
            MUL_ADD: begin
                c = a + b;
            end
            MUL_SUB: begin
                c = a - b;
            end
            default: begin
                c = b;
            end
        endcase
    end
    
    assign hi_out = c[63: 32];
    assign lo_out = c[31: 0]; 
    
endmodule
