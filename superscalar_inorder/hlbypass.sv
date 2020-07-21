`include "mips.svh"

module hlbypass(
        input bypass_upd_t execute,
        input bypass_upd_t commit,
        input bypass_upd_t retire,
        input word_t hi_complete, lo_complete,
        output word_t hidata, lodata
    );

    logic retire_hazard, commit_hazard, execute_hazard;
    logic [1: 0] retire_hit, commit_hit, execute_hit;
    assign execute_hit = {execute.hiwrite[1] | execute.hiwrite[0], execute.lowrite[1] | execute.lowrite[0]};
    assign commit_hit = {commit.hiwrite[1] | commit.hiwrite[0], commit.lowrite[1] | commit.lowrite[0]} & (~execute_hit);
    assign retire_hit = {retire.hiwrite[1] | retire.hiwrite[0], retire.lowrite[1] | retire.lowrite[0]} & (~execute_hit) & (~commit_hit);

    logic [2: 0] hihits;
    assign hihits = {execute_hit[1], commit_hit[1], retire_hit[1]};
    assign hihit = execute_hit[1] | commit_hit[1] | retire_hit[1];
    always_comb begin
        case (hihits)
            3'b100: hidata <= (execute.hiwrite[0]) ? (execute.hidata[0]) : (execute.hidata[1]);
            3'b010: hidata <= (commit.hiwrite[0]) ? (commit.hidata[0]) : (commit.hidata[1]);
            3'b001: hidata <= (retire.hiwrite[0]) ? (retire.hidata[0]) : (retire.hidata[1]);
            default: hidata <= hi_complete;
        endcase
    end

    logic [2: 0] lohits;
    assign hihits = {execute_hit[0], commit_hit[0], retire_hit[0]};
    assign hihit = execute_hit[0] | commit_hit[0] | retire_hit[0];
    always_comb begin
        case (hihits)
            3'b100: lodata <= (execute.lowrite[0]) ? (execute.lodata[0]) : (execute.lodata[1]);
            3'b010: lodata <= (commit.lowrite[0]) ? (commit.lodata[0]) : (commit.lodata[1]);
            3'b001: lodata <= (retire.lowrite[0]) ? (retire.lodata[0]) : (retire.lodata[1]);
            default: lodata <= lo_complete;
        endcase
    end

endmodule