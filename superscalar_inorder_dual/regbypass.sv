`include "mips.svh"

module regbypass(
        input creg_addr_t reg_addr,
        input bypass_upd_t execute,
        input bypass_upd_t commit,
        input bypass_upd_t retire,
        input word_t reg_data_complete,
        output logic hazard,
        output word_t reg_data
    );
    logic retire_hit, commit_hit, execute_hit;
    assign execute_hit = (execute.destreg[1] == reg_addr && execute.wen[1]) | 
                         (execute.destreg[0] == reg_addr && execute.wen[0]);
    assign commit_hit = ((commit.destreg[1] == reg_addr && commit.wen[1]) | 
                        (commit.destreg[0] == reg_addr && commit.wen[0])) & (~execute_hit);
    assign retire_hit = ((retire.destreg[1] == reg_addr && retire.wen[1]) | 
                        (retire.destreg[0] == reg_addr && retire.wen[0])) & (~execute_hit) & (~commit_hit);

    logic mem_hazard1, mem_hazard0, mem_hazard;
    assign mem_hazard1 = (execute.destreg[0] != reg_addr) & (execute.destreg[1] == reg_addr) & (execute.memtoreg[1]);
    assign mem_hazard0 = (execute.destreg[0] == reg_addr) & (execute.memtoreg[0]);
    assign mem_hazard = mem_hazard0 | mem_hazard1;
    assign hazard = mem_hazard;
        
/*    
    logic cp0_hazard1, cp0_hazard0, cp0_hazard;
    assign cp0_hazard1 = (execute.data[1].destreg == reg_addr) & (execute.data[1].instr.ctl.cp0toreg);
    assign cp0_hazard0 = ~(execute.data[1].destreg == reg_addr) & (execute.data[0].destreg == reg_addr) & (execute.data[0].instr.ctl.cp0toreg);
    assign cp0_hazard = cp0_hazard0 | cp0_hazard1;
    assign hazard = mem_hazard | cp0_hazard;
*/
    
    logic [2: 0] hits;
    assign hits = {execute_hit, commit_hit, retire_hit};
    assign hit = execute_hit | commit_hit | retire_hit;
    always_comb begin
        case (hits)
            3'b100: reg_data <= (execute.destreg[0] == reg_addr && execute.wen[0]) ? (execute.result[0]) : (execute.result[1]);
            3'b010: reg_data <= (commit.destreg[0] == reg_addr && commit.wen[0]) ? (commit.result[0]) : (commit.result[1]);
            3'b001: reg_data <= (retire.destreg[0] == reg_addr && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
            default: reg_data <= reg_data_complete;
        endcase
    end
    
endmodule