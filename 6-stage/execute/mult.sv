`include "mips.svh"

module mult (
    input logic clk, reset,
    input word_t a, b,
    input decoded_op_t op,
    output word_t hi, lo,
    output logic ok
);
    dword_t hilo_m, hilo_d;
    multiplier multiplier(.clk, .a, .b, .hilo(hilo_m), .is_signed(op == MULT));
    divider divider(.clk, .reset, .valid(op == DIV || op == DIVU), .is_signed(op == DIV),
                    .a, .b, .hilo(hilo_d));
    assign {hi, lo} = (op==MULT||op == MULTU) ? hilo_m : hilo_d;
    localparam MULT_DELAY = 1 << 4;
    localparam DIV_DELAY = 1 << 17;
    logic [17:0] counter, counter_new;
    localparam type state_t = enum logic {INIT, DOING};
    state_t state, state_new;
    assign ok = state_new == INIT;

    always_comb begin
        state_new = state;
        counter_new = counter;
        case (state)
            INIT: begin
                case (op)
                    MULTU: begin
                        counter_new = MULT_DELAY; 
                        state_new = DOING;
                    end
                    MULT: begin
                        counter_new = MULT_DELAY; 
                        state_new = DOING;
                    end
                    DIVU: begin
                        counter_new = DIV_DELAY; 
                        state_new = DOING;
                    end
                    DIV: begin
                        counter_new = DIV_DELAY; 
                        state_new = DOING;
                    end
                    default: begin
                        
                    end
                endcase
            end
            DOING: begin
                counter_new = {1'b0, counter_new[17:1]};
                if (counter_new == 0) begin
                    state_new = INIT;
                end
            end
            default: begin
                
            end
        endcase
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= INIT;
            counter <= '0;
        end else begin
            state <= state_new;
            counter <= counter_new;
        end
    end
endmodule