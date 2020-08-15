`include "mips.svh"

module cp0status_bypass(
        input bypass_upd_t execute, commitex, commitdt, retire,
        input cp0_status_t cp0_status, 
        input cp0_cause_t cp0_cause,
        input word_t epc,
        output cp0_status_t cp0_status_out,
        output cp0_cause_t cp0_cause_out,
        output word_t epc_out
    );
    
    rf_w_t _execute, _commitex, _commitdt, _retire;
    assign _execute = (execute.cp0_wen[1] && execute.cp0_addr[1] == 5'd13) ? 
                      ({execute.cp0_wen[1], execute.cp0_addr[1], execute.result[1]}) : 
                      ({execute.cp0_wen[0], execute.cp0_addr[0], execute.result[0]});
    assign _commitex = (commitex.cp0_wen[1] && commitex.cp0_addr[1] == 5'd13) ? 
                     ({commitex.cp0_wen[1], commitex.cp0_addr[1], commitex.result[1]}) : 
                     ({commitex.cp0_wen[0], commitex.cp0_addr[0], commitex.result[0]});
	assign _commitdt = (commitdt.cp0_wen[1] && commitdt.cp0_addr[1] == 5'd13) ? 
                     ({commitdt.cp0_wen[1], commitdt.cp0_addr[1], commitdt.result[1]}) : 
                     ({commitdt.cp0_wen[0], commitdt.cp0_addr[0], commitdt.result[0]});
    assign _retire = (retire.cp0_wen[1] && retire.cp0_addr[1] == 5'd13) ? 
                     ({retire.cp0_wen[1], retire.cp0_addr[1], retire.result[1]}) : 
                     ({retire.cp0_wen[0], retire.cp0_addr[0], retire.result[0]});  

    rf_w_t __execute, __commitex, __commitdt, __retire;
    assign __execute = (execute.cp0_wen[1] && execute.cp0_addr[1] == 5'd12) ? 
                       ({execute.cp0_wen[1], execute.cp0_addr[1], execute.result[1]}) : 
                       ({execute.cp0_wen[0], execute.cp0_addr[0], execute.result[0]});
    assign __commitex = (commitex.cp0_wen[1] && commitex.cp0_addr[1] == 5'd12) ? 
                      ({commitex.cp0_wen[1], commitex.cp0_addr[1], commitex.result[1]}) : 
                      ({commitex.cp0_wen[0], commitex.cp0_addr[0], commitex.result[0]});
	assign __commitdt = (commitdt.cp0_wen[1] && commitdt.cp0_addr[1] == 5'd12) ? 
                      ({commitdt.cp0_wen[1], commitdt.cp0_addr[1], commitdt.result[1]}) : 
                      ({commitdt.cp0_wen[0], commitdt.cp0_addr[0], commitdt.result[0]});                      
    assign __retire = (retire.cp0_wen[1] && retire.cp0_addr[1] == 5'd12) ? 
                      ({retire.cp0_wen[1], retire.cp0_addr[1], retire.result[1]}) : 
                      ({retire.cp0_wen[0], retire.cp0_addr[0], retire.result[0]});  

    rf_w_t ___execute, ___commitex, ___commitdt, ___retire;
    assign ___execute = (execute.cp0_wen[1] && execute.cp0_addr[1] == 5'd14) ? 
                        ({execute.cp0_wen[1], execute.cp0_addr[1], execute.result[1]}) : 
                        ({execute.cp0_wen[0], execute.cp0_addr[0], execute.result[0]});
    assign ___commitex = (commitex.cp0_wen[1] && commitex.cp0_addr[1] == 5'd14) ? 
                       ({commitex.cp0_wen[1], commitex.cp0_addr[1], commitex.result[1]}) : 
                       ({commitex.cp0_wen[0], commitex.cp0_addr[0], commitex.result[0]});
	assign ___commitdt = (commitdt.cp0_wen[1] && commitdt.cp0_addr[1] == 5'd14) ? 
                       ({commitdt.cp0_wen[1], commitdt.cp0_addr[1], commitdt.result[1]}) : 
                       ({commitdt.cp0_wen[0], commitdt.cp0_addr[0], commitdt.result[0]});                       
    assign ___retire = (retire.cp0_wen[1] && retire.cp0_addr[1] == 5'd14) ? 
                       ({retire.cp0_wen[1], retire.cp0_addr[1], retire.result[1]}) : 
                       ({retire.cp0_wen[0], retire.cp0_addr[0], retire.result[0]});                        

 
    always_comb
        begin
            cp0_status_out = cp0_status;
            cp0_cause_out = cp0_cause;
            epc_out = epc;
            if (_execute.wen && _execute.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _execute.wd[9:8];
            end else if (_commitex.wen && _commitex.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _commitex.wd[9:8];
			end else if (_commitdt.wen && _commitdt.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _commitdt.wd[9:8];                
            end else if (_retire.wen && _retire.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _retire.wd[9:8];
            end
            
            if (__execute.wen && __execute.addr == 5'd12) begin
                cp0_status_out.IM = __execute.wd[15:8];
                cp0_status_out.EXL = __execute.wd[1];
                cp0_status_out.IE = __execute.wd[0];
            end else if (__commitex.wen && __commitex.addr == 5'd12) begin
                cp0_status_out.IM = __commitex.wd[15:8];
                cp0_status_out.EXL = __commitex.wd[1];
                cp0_status_out.IE = __commitex.wd[0];
			end else if (__commitdt.wen && __commitdt.addr == 5'd12) begin
                cp0_status_out.IM = __commitdt.wd[15:8];
                cp0_status_out.EXL = __commitdt.wd[1];
                cp0_status_out.IE = __commitdt.wd[0];                
            end else if (__retire.wen && __retire.addr == 5'd12) begin
                cp0_status_out.IM = __retire.wd[15:8];
                cp0_status_out.EXL = __retire.wd[1];
                cp0_status_out.IE = __retire.wd[0];
            end
            
            if (___execute.wen && ___execute.addr == 5'd14) begin
                epc_out = ___execute.wd;
            end else if (___commitex.wen && ___commitex.addr == 5'd14) begin
                epc_out = ___commitex.wd;
			end else if (___commitdt.wen && ___commitdt.addr == 5'd14) begin
                epc_out = ___commitdt.wd;                
            end else if (___retire.wen && ___retire.addr == 5'd14) begin
                epc_out = ___retire.wd;
            end
        end                                                
    
endmodule
