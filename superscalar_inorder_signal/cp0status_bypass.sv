`include "mips.svh"

module cp0status_bypass(
        input bypass_upd_t execute, commit, retire,
        input cp0_status_t cp0_status, 
        input cp0_cause_t cp0_cause,
        input word_t epc,
        output cp0_status_t cp0_status_out,
        output cp0_cause_t cp0_cause_out,
        output word_t epc_out
    );
    
    rf_w_t _execute, _commit, _retire;
    assign _execute = (execute.cp0_wen[1] && execute.cp0_addr[1] == 5'd13) ? 
                      ({execute.cp0_wen[1], execute.cp0_addr[1], execute.result[1]}) : 
                      ({execute.cp0_wen[0], execute.cp0_addr[0], execute.result[0]});
    assign _commit = (commit.cp0_wen[1] && commit.cp0_addr[1] == 5'd13) ? 
                     ({commit.cp0_wen[1], commit.cp0_addr[1], commit.result[1]}) : 
                     ({commit.cp0_wen[0], commit.cp0_addr[0], commit.result[0]});
    assign _retire = (retire.cp0_wen[1] && retire.cp0_addr[1] == 5'd13) ? 
                     ({retire.cp0_wen[1], retire.cp0_addr[1], retire.result[1]}) : 
                     ({retire.cp0_wen[0], retire.cp0_addr[0], retire.result[0]});  

    rf_w_t __execute, __commit, __retire;
    assign __execute = (execute.cp0_wen[1] && execute.cp0_addr[1] == 5'd12) ? 
                       ({execute.cp0_wen[1], execute.cp0_addr[1], execute.result[1]}) : 
                       ({execute.cp0_wen[0], execute.cp0_addr[0], execute.result[0]});
    assign __commit = (commit.cp0_wen[1] && commit.cp0_addr[1] == 5'd12) ? 
                      ({commit.cp0_wen[1], commit.cp0_addr[1], commit.result[1]}) : 
                      ({commit.cp0_wen[0], commit.cp0_addr[0], commit.result[0]});
    assign __retire = (retire.cp0_wen[1] && retire.cp0_addr[1] == 5'd12) ? 
                      ({retire.cp0_wen[1], retire.cp0_addr[1], retire.result[1]}) : 
                      ({retire.cp0_wen[0], retire.cp0_addr[0], retire.result[0]});  

    rf_w_t ___execute, ___commit, ___retire;
    assign ___execute = (execute.cp0_wen[1] && execute.cp0_addr[1] == 5'd14) ? 
                        ({execute.cp0_wen[1], execute.cp0_addr[1], execute.result[1]}) : 
                        ({execute.cp0_wen[0], execute.cp0_addr[0], execute.result[0]});
    assign ___commit = (commit.cp0_wen[1] && commit.cp0_addr[1] == 5'd14) ? 
                       ({commit.cp0_wen[1], commit.cp0_addr[1], commit.result[1]}) : 
                       ({commit.cp0_wen[0], commit.cp0_addr[0], commit.result[0]});
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
            end else if (_retire.wen && _commit.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _commit.wd[9:8];
            end else if (_retire.wen && _retire.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _retire.wd[9:8];
            end
            
            if (__execute.wen && __execute.addr == 5'd12) begin
                cp0_status_out.IM = __execute.wd[15:8];
                cp0_status_out.EXL = __execute.wd[1];
                cp0_status_out.IE = __execute.wd[0];
            end else if (__commit.wen && __commit.addr == 5'd12) begin
                cp0_status_out.IM = __commit.wd[15:8];
                cp0_status_out.EXL = __commit.wd[1];
                cp0_status_out.IE = __commit.wd[0];
            end else if (__retire.wen && __retire.addr == 5'd12) begin
                cp0_status_out.IM = __retire.wd[15:8];
                cp0_status_out.EXL = __retire.wd[1];
                cp0_status_out.IE = __retire.wd[0];
            end
            
            if (___execute.wen && ___execute.addr == 5'd14) begin
                epc_out = ___execute.wd;
            end else if (___commit.wen && ___commit.addr == 5'd14) begin
                epc_out = ___commit.wd;
            end else if (___retire.wen && ___retire.addr == 5'd14) begin
                epc_out = ___retire.wd;
            end
        end                                                
    
endmodule
