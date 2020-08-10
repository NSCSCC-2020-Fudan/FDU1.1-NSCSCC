`include "mips.svh"

module retirebypass(
        input creg_addr_t [4: 0] reg_addrC,
        output word_t [4: 0] reg_dataC, 
        output word_t [1: 0] hilodataC,
        //issue
        input bypass_upd_t retire,
        //forward
        output creg_addr_t [4: 0] reg_addrR,
        input word_t [4: 0] reg_dataR,
        input word_t hiR, loR
    );
    
    assign reg_addrR = reg_addrC;
    
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
    
    assign reg_dataC[4] = (~retire_hit[4])                                     ? (reg_dataR[4]) :                         
                          (retire.destreg[0] == reg_addrC[4] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
    assign reg_dataC[3] = (~retire_hit[3])                                     ? (reg_dataR[3]) :                         
                          (retire.destreg[0] == reg_addrC[3] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
    assign reg_dataC[2] = (~retire_hit[2])                                     ? (reg_dataR[2]) :                         
                          (retire.destreg[0] == reg_addrC[2] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);                          
    assign reg_dataC[1] = (~retire_hit[1])                                     ? (reg_dataR[1]) :                         
                          (retire.destreg[0] == reg_addrC[1] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);
    assign reg_dataC[0] = (~retire_hit[0])                                     ? (reg_dataR[0]) :                         
                          (retire.destreg[0] == reg_addrC[0] && retire.wen[0]) ? (retire.result[0]) : (retire.result[1]);                                                    
    
    
    assign hilo_hit = {retire.hiwrite[1] | retire.hiwrite[0], retire.lowrite[1] | retire.lowrite[0]};
    assign hilodataC[1] = (~hilo_hit)         ? (hiR)              : 
                          (retire.hiwrite[0]) ? (retire.hidata[0]) : (retire.hidata[1]);
    assign hilodataC[0] = (~hilo_hit)         ? (loR)              : 
                          (retire.lowrite[0]) ? (retire.lodata[0]) : (retire.lodata[1]);                           
                                                                                            
endmodule
