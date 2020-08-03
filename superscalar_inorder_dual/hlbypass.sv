`include "mips.svh"

module hlbypass(
        input bypass_upd_t execute,
        input bypass_upd_t commitex, commitdt,
        input bypass_upd_t retire,
        input word_t hi_complete, lo_complete,
        output word_t hidata, lodata
    );

    logic retire_hazard, commitex_hazard, commitdt_hazard, execute_hazard;
    logic [1: 0] retire_hit, commitex_hit, commitdt_hit, execute_hit;
    assign execute_hit = {execute.hiwrite[1] | execute.hiwrite[0], execute.lowrite[1] | execute.lowrite[0]};
    assign commitex_hit = {commitex.hiwrite[1] | commitex.hiwrite[0], commitex.lowrite[1] | commitex.lowrite[0]} & (~execute_hit);
    assign commitdt_hit = {commitdt.hiwrite[1] | commitdt.hiwrite[0], commitdt.lowrite[1] | commitdt.lowrite[0]} & (~execute_hit) & (~commitex_hit);
    assign retire_hit = {retire.hiwrite[1] | retire.hiwrite[0], retire.lowrite[1] | retire.lowrite[0]} & (~execute_hit) & (~commitex_hit) & (~commitdt_hit);

    logic [3: 0] hihits;
    assign hihits = {execute_hit[1], commitex_hit[1], commitdt_hit[1], retire_hit[1]};
    //assign hihit = execute_hit[1] | commit_hit[1] | retire_hit[1];
    always_comb begin
        case (hihits)
            4'b1000: hidata <= (execute.hiwrite[0]) ? (execute.hidata[0]) : (execute.hidata[1]);
            4'b0100: hidata <= (commitex.hiwrite[0]) ? (commitex.hidata[0]) : (commitex.hidata[1]);
            4'b0010: hidata <= (commitdt.hiwrite[0]) ? (commitdt.hidata[0]) : (commitdt.hidata[1]);
            4'b0001: hidata <= (retire.hiwrite[0]) ? (retire.hidata[0]) : (retire.hidata[1]);
            default: hidata <= hi_complete;
        endcase
    end

    logic [3: 0] lohits;
    assign lohits = {execute_hit[0], commitex_hit[0], commitdt_hit[0], retire_hit[0]};
    //assign lohit = execute_hit[0] | commit_hit[0] | retire_hit[0];
    always_comb begin
        case (lohits)
            4'b1000: lodata <= (execute.lowrite[0]) ? (execute.lodata[0]) : (execute.lodata[1]);
            4'b0100: lodata <= (commitex.lowrite[0]) ? (commitex.lodata[0]) : (commitex.lodata[1]);
            4'b0010: lodata <= (commitdt.lowrite[0]) ? (commitdt.lodata[0]) : (commitdt.lodata[1]);
            4'b0001: lodata <= (retire.lowrite[0]) ? (retire.lodata[0]) : (retire.lodata[1]);
            default: lodata <= lo_complete;
        endcase
    end

endmodule