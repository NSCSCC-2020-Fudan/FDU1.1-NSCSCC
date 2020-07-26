`include "mips.svh"

module cp0bypass(
        input creg_addr_t cp0_addr,
        input bypass_upd_t execute,
        input bypass_upd_t commit,
        input bypass_upd_t retire,
        input word_t cp0_data_complete,
        output word_t cp0_data
    );
    logic regire_hit, commit_hit, execute_hit;
    assign execute_hit = (execute.cp0_addr[1] == cp0_addr && execute.cp0_wen[1]) | 
                         (execute.cp0_addr[0] == cp0_addr && execute.cp0_wen[0]);
    assign commit_hit = ((commit.cp0_addr[1] == cp0_addr && commit.cp0_wen[1]) | 
                        (commit.cp0_addr[0] == cp0_addr && commit.cp0_wen[0])) & (~execute_hit);
    assign retire_hit = ((retire.cp0_addr[1] == cp0_addr && execute.cp0_wen[1]) | 
                        (retire.cp0_addr[0] == cp0_addr && execute.cp0_wen[0])) & (~execute_hit) & (~commit_hit);
    
    logic [2: 0] hits;
    assign hits = {execute_hit, commit_hit, retire_hit};
    assign hit = execute_hit | commit_hit | retire_hit;
    always_comb begin
        case (hits)
            3'b100: cp0_data <= (execute.cp0_addr[0] == cp0_addr && execute.cp0_wen[0]) ? (execute.result[0]) : (execute.result[1]);
            3'b010: cp0_data <= (commit.cp0_addr[0] == cp0_addr && commit.cp0_wen[0]) ? (commit.result[0]) : (commit.result[1]);
            3'b001: cp0_data <= (retire.cp0_addr[0] == cp0_addr && retire.cp0_wen[0]) ? (retire.result[0]) : (retire.result[1]);
            default: cp0_data <= cp0_data_complete;
        endcase
    end
    
endmodule