`include "mips.svh"

module jrpredict(
        input logic clk, reset, en,
        input logic [1: 0] push,
        input word_t [1: 0] pc,//jal
        input logic [1: 0]  pop,//jr
        //fetch
        input logic top_reset,
        input logic[`JR_ENTRY_WIDTH - 1: 0] top_commit,
        //commit
        output logic[`JR_ENTRY_WIDTH - 1: 0] jr_point,
        output word_t pc_jr
    );
    
    word_t pcplus8;
    assign pcplus8 = (push[1] | pop[1]) ? (pc[1] + 5'b01000) : (pc[0] + 5'b01000);
    jrstack jrstak(clk, reset,
                   (push[1] | push[0]) & en,
                   pcplus8,
                   (pop[1] | pop[0]) & en,
                   top_reset, top_commit,
                   jr_point, pc_jr);
    
endmodule
