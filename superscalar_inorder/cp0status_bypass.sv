`include "mips.svh"

module cp0status_bypass(
        input bypass_upd_t execute, commit, retire,
        input cp0_status_t cp0_status, 
        input cp0_cause_t cp0_cause,
        output cp0_status_t cp0_status_out,
        output cp0_cause_t cp0_cause_out
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
 
    always_comb
        begin
            cp0_status_out = cp0_status;
            cp0_cause_out = cp0_cause;
            if (_execute.wen && _execute.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _execute.wd[9:8];
            end else if (_retire.wen && _commit.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _commit.wd[9:8];
            end else if (_retire.wen && _retire.addr == 5'd13) begin
                cp0_cause_out.IP[1:0] = _retire.wd[9:8];
            end
            
            if (_execute.wen && _execute.addr == 5'd12) begin
                cp0_status_out.IM = _execute.wd[15:8];
                cp0_status_out.EXL = _execute.wd[1];
                cp0_status_out.IE = _execute.wd[0];
            end else if (_commit.wen && _commit.addr == 5'd12) begin
                cp0_status_out.IM = _commit.wd[15:8];
                cp0_status_out.EXL = _commit.wd[1];
                cp0_status_out.IE = _commit.wd[0];
            end else if (_retire.wen && _retire.addr == 5'd12) begin
                cp0_status_out.IM = _retire.wd[15:8];
                cp0_status_out.EXL = _retire.wd[1];
                cp0_status_out.IE = _retire.wd[0];
            end
        end                                                
    
endmodule
