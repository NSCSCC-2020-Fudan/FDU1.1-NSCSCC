  
`include "mips.svh"

module handshake (
    input logic clk, reset,
    input logic cpu_req,
    input logic addr_ok, data_ok,
    output logic cpu_data_ok, req
);
    
    typedef enum logic[1:0] { INIT, WAIT_ADDR, WAIT_DATA } handshake_state_t;
    handshake_state_t state, state_new;
    assign cpu_data_ok = state_new == INIT;
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= INIT;
        end else begin
            state <= state_new;
        end
    end
    always_comb begin
        state_new = state;
        case (state)
                INIT: begin
                    if (cpu_req) begin
                        state_new = WAIT_ADDR;
                    end
                end
                WAIT_ADDR: begin
                    if (addr_ok) begin
                        state_new = WAIT_DATA;
                        if (data_ok) begin
                            state_new = INIT;
                        end
                    end
                end
                WAIT_DATA: begin
                    if (data_ok) begin
                        state_new = INIT;
                    end
                end
                default: begin
                    state_new = INIT;
                end
            endcase
    end
    assign req = state == WAIT_ADDR;
endmodule