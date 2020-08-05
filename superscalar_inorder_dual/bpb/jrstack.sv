`include "mips.svh"

module jrstack(
        input logic clk, reset,
        input logic push,
        input word_t pc,//jal
        input logic pop,//jr
        //fetch
        input logic top_reset,
        input logic[`JR_ENTRY_WIDTH - 1: 0] top_commit,
        //commit
        output logic[`JR_ENTRY_WIDTH - 1: 0] jr_point,
        output word_t pc_jr 
    );
    
    word_t [`JR_ENTRIES - 1: 0] jr_stack, jr_stack_;
    logic [`JR_ENTRY_WIDTH - 1: 0] top, topplus1, topminus1, top_;
       
    assign topplus1 = top + 2'b01;
    assign topminus1 = top - 2'b01;
    always_comb
        begin
            top_ = top;
            jr_stack_ = jr_stack;
            if (push)
                begin
                    top_ = topplus1;
                    jr_stack_[topplus1] = pc;
                end
            if (pop)
                begin
                    top_ = topminus1;
                    jr_stack_[top] = '0;
                end
            if (pop & push)
                begin
                    top_ = top;
                    jr_stack_[top] = pc;
                end                
            if (top_reset)
                top_ = top_commit;
        end            
    
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    top <= '0;
                    jr_stack <= `JR_STACK_INIT;
                end
            else
                begin
                    jr_stack <= jr_stack_;
                    top <= top_;
                end
        end 
    
    assign pc_jr = jr_stack[top];
    assign jr_point = top;
endmodule
