module mult 
    import common::*;
    import decode_pkg::*;
    import issue_pkg::*;
    import commit_pkg::*;(
    input logic clk, resetn, flush,
    input word_t a, b,
    input decoded_op_t op,
    // output word_t hi, lo,
    input issued_instr_t mult_issue,
    output mult_commit_t mult_commit,
    output logic ok
);
    issued_instr_t mult_issue_2;
    word_t a_2, b_2;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            mult_issue_2 <= '0;
            {a_2, b_2} <= '0;
        end else if(state == INIT)begin
            mult_issue_2 <= mult_issue;
            {a_2, b_2} <= {a, b};
        end
    end
    dword_t hilo_m, hilo_d;
    word_t hi, lo;
    multiplier multiplier(.clk, .a(a_2), .b(b_2), .hilo(hilo_m), .is_signed(mult_issue_2.op == MULT));
    divider divider(.clk, .resetn, .flush, .valid(mult_issue_2.op == DIV || mult_issue_2.op == DIVU), .is_signed(mult_issue_2.op == DIV),
                    .a(a_2), .b(b_2), .hilo(hilo_d));
    assign {hi, lo} = (mult_issue_2.op==MULT||mult_issue_2.op == MULTU) ? hilo_m : hilo_d;
    localparam MULT_DELAY = 1 << 5;
    localparam DIV_DELAY = 1 << 17;
    logic [17:0] counter, counter_new;
    localparam type state_t = enum logic {INIT, DOING};
    state_t state, state_new;
    assign ok = state == INIT;

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
        if (~resetn | flush) begin
            state <= INIT;
            counter <= '0;
        end else begin
            state <= state_new;
            counter <= counter_new;
        end
    end

    assign mult_commit.valid = mult_issue_2.valid && state_new == INIT && state == DOING;
    assign mult_commit.hi = hi;
    assign mult_commit.lo = lo;
    assign mult_commit.rob_addr = mult_issue_2.dst;
    assign mult_commit.exception = mult_issue_2.exception;
    // dword_t ans;
    // always_comb begin
    //     case (op)
    //         MULTU: begin
    //             ans = {32'b0, a} * {32'b0, b};
    //             hi = ans[63:32];
    //             lo = ans[31:0];
    //         end
    //         MULT: begin
    //             ans = signed'({{32{a[31]}}, a}) * signed'({{32{b[31]}}, b});
    //             hi = ans[63:32];
    //             lo = ans[31:0];
    //         end
    //         DIVU: begin
    //             ans = '0;
    //             lo = {1'b0, a} / {1'b0, b};
    //             hi = {1'b0, a} % {1'b0, b};
    //         end
    //         DIV: begin
    //             ans = '0;
    //             lo = signed'(a) / signed'(b);
    //             hi = signed'(a) % signed'(b);
    //         end
    //         default: begin
    //             hi = '0;
    //             lo = '0;
    //             ans = '0;
    //         end
    //     endcase
    // end
endmodule