`include "mips.svh"

module retirebypass(
        input creg_addr_t [4: 0] reg_addrC,
        output word_t [4: 0] reg_dataC, 
        output word_t [1: 0] hilodataC,
        //issue
        input bypass_upd_t retire,
        input bypass_upd_t commit,
        //forward
        output creg_addr_t [4: 0] reg_addrR,
        input word_t [4: 0] reg_dataR,
        input word_t hiR, loR
    );
    
    assign reg_addrR = reg_addrC;
    
    logic [4: 0] commit_hit;
    assign commit_hit[4] = ((commit.destreg[1] == reg_addrC[4] && commit.wen[1]) | 
                            (commit.destreg[0] == reg_addrC[4] && commit.wen[0]));
    assign commit_hit[3] = ((commit.destreg[1] == reg_addrC[3] && commit.wen[1]) | 
                            (commit.destreg[0] == reg_addrC[3] && commit.wen[0]));
    assign commit_hit[2] = ((commit.destreg[1] == reg_addrC[2] && commit.wen[1]) | 
                            (commit.destreg[0] == reg_addrC[2] && commit.wen[0]));
    assign commit_hit[1] = ((commit.destreg[1] == reg_addrC[1] && commit.wen[1]) | 
                            (commit.destreg[0] == reg_addrC[1] && commit.wen[0]));
    assign commit_hit[0] = ((commit.destreg[1] == reg_addrC[0] && commit.wen[1]) | 
                            (commit.destreg[0] == reg_addrC[0] && commit.wen[0]));


    logic [4: 0] retire_hit;
    assign retire_hit[4] = ((retire.destreg[1] == reg_addrC[4] && retire.wen[1]) | 
                            (retire.destreg[0] == reg_addrC[4] && retire.wen[0]));
    assign retire_hit[3] = ((retire.destreg[1] == reg_addrC[3] && retire.wen[1]) | 
                            (retire.destreg[0] == reg_addrC[3] && retire.wen[0]));
    assign retire_hit[2] = ((retire.destreg[1] == reg_addrC[2] && retire.wen[1]) | 
                            (retire.destreg[0] == reg_addrC[2] && retire.wen[0]));
    assign retire_hit[1] = ((retire.destreg[1] == reg_addrC[1] && retire.wen[1]) | 
                            (retire.destreg[0] == reg_addrC[1] && retire.wen[0]));
    assign retire_hit[0] = ((retire.destreg[1] == reg_addrC[0] && retire.wen[1]) | 
                            (retire.destreg[0] == reg_addrC[0] && retire.wen[0]));

    
    always_comb 
        begin
            if (commit_hit[4])
                reg_dataC[4] = (commit.destreg[0] == reg_addrC[4] && commit.wen[0]) ? (commit.result[0]) : (commit.result[1]);
            else 
                begin
                    if (retire_hit[4])
                        reg_dataC[4] = (retire.destreg[0] == reg_addrC[4] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
                    else
                        reg_dataC[4] = reg_dataR[4];
                end 
            
            if (commit_hit[3])
                reg_dataC[3] = (commit.destreg[0] == reg_addrC[3] && commit.wen[0]) ? (commit.result[0]) : (commit.result[1]);
            else 
                begin
                    if (retire_hit[3])
                        reg_dataC[3] = (retire.destreg[0] == reg_addrC[3] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
                    else
                        reg_dataC[3] = reg_dataR[3];
                end
                
            if (commit_hit[2])
                reg_dataC[2] = (commit.destreg[0] == reg_addrC[2] && commit.wen[0]) ? (commit.result[0]) : (commit.result[1]);
            else 
                begin
                    if (retire_hit[2])
                        reg_dataC[2] = (retire.destreg[0] == reg_addrC[2] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
                    else
                        reg_dataC[2] = reg_dataR[2];
                end

            if (commit_hit[1])
                reg_dataC[1] = (commit.destreg[0] == reg_addrC[1] && commit.wen[0]) ? (commit.result[0]) : (commit.result[1]);
            else 
                begin
                    if (retire_hit[1])
                        reg_dataC[1] = (retire.destreg[0] == reg_addrC[1] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
                    else
                        reg_dataC[1] = reg_dataR[1];
                end
            
            if (commit_hit[0])
                reg_dataC[0] = (commit.destreg[0] == reg_addrC[0] && commit.wen[0]) ? (commit.result[0]) : (commit.result[1]);
            else 
                begin
                    if (retire_hit[0])
                        reg_dataC[0] = (retire.destreg[0] == reg_addrC[0] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
                    else
                        reg_dataC[0] = reg_dataR[0];
                end
        end

    always_comb 
        begin
            if (commit.hiwrite[1] | commit.hiwrite[0])
                hilodataC[1] = (commit.hiwrite[0]) ? (commit.hidata[0]) : (commit.hidata[1]);
            else 
                begin
                    if (retire.hiwrite[1] | retire.hiwrite[0])
                        hilodataC[1] = (retire.hiwrite[0]) ? (retire.hidata[0]) : (retire.hidata[1]);
                    else
                        hilodataC[1] = hiR;
                end
            
            if (commit.lowrite[1] | commit.lowrite[0])
                hilodataC[0] = (commit.lowrite[0]) ? (commit.lodata[0]) : (commit.lodata[1]);
            else 
                begin
                    if (retire.lowrite[1] | retire.lowrite[0])
                        hilodataC[0] = (retire.lowrite[0]) ? (retire.lodata[0]) : (retire.lodata[1]);
                    else
                        hilodataC[0] = loR;
                end
        end                         
                                                                                            
endmodule
