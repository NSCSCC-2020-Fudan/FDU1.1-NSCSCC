`include "mips.svh"

module cp0bypass(
        input creg_addr_t cp0_addr,
        input bypass_upd_t execute,
        input bypass_upd_t commitex, commitdt,
        input bypass_upd_t retire,
        input word_t cp0_data_complete,
        output word_t cp0_data
    );
    /*
    logic regire_hit, commit_hit, execute_hit;
    assign execute_hit = (execute.cp0_addr[1] == cp0_addr && execute.cp0_wen[1]) | 
                         (execute.cp0_addr[0] == cp0_addr && execute.cp0_wen[0]);
    assign commitex_hit = ((commitex.cp0_addr[1] == cp0_addr && commitex.cp0_wen[1]) | 
                          (commitex.cp0_addr[0] == cp0_addr && commitex.cp0_wen[0])) & (~execute_hit);
	assign commitdt_hit = ((commitdt.cp0_addr[1] == cp0_addr && commitdt.cp0_wen[1]) | 
                          (commitdt.cp0_addr[0] == cp0_addr && commitdt.cp0_wen[0])) & (~execute_hit) & (~commitex_hit);
    assign retire_hit = ((retire.cp0_addr[1] == cp0_addr && execute.cp0_wen[1]) | 
                        (retire.cp0_addr[0] == cp0_addr && execute.cp0_wen[0])) & (~execute_hit) & (~commitex_hit) & (~commitdt_hit);
    
    logic [3: 0] hits;
    assign hits = {execute_hit, commitex_hit, commitdt_hit, retire_hit};
    //assign hit = execute_hit | commitex_hit | commitdt_hit | retire_hit;
    always_comb begin
        case (hits)
            4'b1000: cp0_data <= (execute.cp0_addr[0] == cp0_addr && execute.cp0_wen[0]) ? (execute.result[0]) : (execute.result[1]);
            4'b0100: cp0_data <= (commitex.cp0_addr[0] == cp0_addr && commitex.cp0_wen[0]) ? (commitex.result[0]) : (commitex.result[1]);
            4'b0010: cp0_data <= (commitdt.cp0_addr[0] == cp0_addr && commitdt.cp0_wen[0]) ? (commitdt.result[0]) : (commitdt.result[1]);
            4'b0001: cp0_data <= (retire.cp0_addr[0] == cp0_addr && retire.cp0_wen[0]) ? (retire.result[0]) : (retire.result[1]);
            default: cp0_data <= cp0_data_complete;
        endcase
    end
    */
    assign cp0_data = cp0_data_complete;
endmodule