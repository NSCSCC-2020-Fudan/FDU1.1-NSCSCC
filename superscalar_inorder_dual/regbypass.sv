`include "mips.svh"

module regbypass(
        input creg_addr_t reg_addr,
        input bypass_upd_t execute,
        input bypass_upd_t commitex, commitdt,
        input bypass_upd_t retire,
        input word_t reg_data_complete,
        output logic hazard,
        output word_t reg_data
    );
    logic retire_hit, commitex_hit, commitdt_hit, execute_hit;
    assign execute_hit = (execute.destreg[1] == reg_addr && execute.wen[1]) | 
                         (execute.destreg[0] == reg_addr && execute.wen[0]);
    assign commitex_hit = ((commitex.destreg[1] == reg_addr && commitex.wen[1]) | 
                    	  (commitex.destreg[0] == reg_addr && commitex.wen[0])) & (~execute_hit);
	assign commitdt_hit = ((commitdt.destreg[1] == reg_addr && commitdt.wen[1]) | 
                    	  (commitdt.destreg[0] == reg_addr && commitdt.wen[0])) & (~execute_hit) & ~(commitex_hit);                    	  
    assign retire_hit = ((retire.destreg[1] == reg_addr && retire.wen[1]) | 
                        (retire.destreg[0] == reg_addr && retire.wen[0])) & (~execute_hit) & (~commitex_hit) & (~commitdt_hit);
/*
    logic mem_hazard1, mem_hazard0, mem_hazard;
    assign mem_hazard1 = (execute.destreg[0] != reg_addr) & (execute.destreg[1] == reg_addr) & (execute.memtoreg[1]);
    assign mem_hazard0 = (execute.destreg[0] == reg_addr) & (execute.memtoreg[0]);
    assign mem_hazard = mem_hazard0 | mem_hazard1;
    assign hazard = mem_hazard;
*/            
    logic exec_hazard1, exec_hazard0, exec_hazard;
    assign cmt_hazard1 = (execute.destreg[0] != reg_addr) & (execute.destreg[1] != reg_addr) & (commitex.destreg[0] != reg_addr) & (commitex.destreg[1] == reg_addr) & (commitex.memtoreg[1]);
    assign cmt_hazard0 = (execute.destreg[0] != reg_addr) & (execute.destreg[1] != reg_addr) & (commitex.destreg[0] == reg_addr) & (commitex.memtoreg[0]);
    assign exec_hazard1 = (execute.destreg[0] != reg_addr) & (execute.destreg[1] == reg_addr) & (execute.memtoreg[1]);
    assign exec_hazard0 = (execute.destreg[0] == reg_addr) & (execute.memtoreg[0]);
    assign hazard = exec_hazard1 | exec_hazard0 | cmt_hazard1 | cmt_hazard0;

    logic zero;
    assign zero = (reg_addr == '0);
    
    logic [3: 0] hits;
    assign hits = {execute_hit & ~zero, commitex_hit & ~zero, commitdt_hit & ~zero, retire_hit & ~zero};
    //assign hit = execute_hit | commitex_hit | retire_hit;
    always_comb begin
        case (hits)
            4'b1000: reg_data <= (execute.destreg[0] == reg_addr && execute.wen[0]) ? (execute.result[0]) : (execute.result[1]);
            4'b0100: reg_data <= (commitex.destreg[0] == reg_addr && commitex.wen[0]) ? (commitex.result[0]) : (commitex.result[1]);
            4'b0010: reg_data <= (commitdt.destreg[0] == reg_addr && commitdt.wen[0]) ? (commitdt.result[0]) : (commitdt.result[1]);
            4'b0001: reg_data <= (retire.destreg[0] == reg_addr && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
            default: reg_data <= reg_data_complete;
        endcase
    end
    
endmodule