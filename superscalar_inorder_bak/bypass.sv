`include "mips.svh"

module bypass(
        input creg_addr_t [3: 0] reg_addrI,
        output word_t [3: 0] reg_dataI,
        input logic [1: 0] hiloreadI, 
        output word_t [1: 0] hilodataI,
        //input creg_addr_t [1: 0] cp0_addrI,
        //output word_t [1: 0] cp0_dataI,
        input logic [3: 0] dhazard_maskI,
        output logic data_hazardI,
        output logic [3: 0] readyI,
        //issue
        input bypass_upd_t execute,
        input bypass_upd_t commitex,
        input bypass_upd_t commitdt,
        input bypass_upd_t retire,
        //forward
        output creg_addr_t [3: 0] reg_addrR,
        input word_t [3: 0] reg_dataR,
        output logic [1: 0] hiloreadR, 
        input word_t hiR, loR
        //output creg_addr_t [1: 0] cp0_addrR,
        //input word_t [1: 0] cp0_dataR
        //registers 
    );
    
    assign reg_addrR = reg_addrI;
    assign hiloreadR = hiloreadI;
    
    //assign cp0_mask_and = `CP0_MASK_AND;
    //assign cp0_mask_or = `CP0_MASK_OR;
    
    logic [3: 0] hazard;
    regbypass bypss_reg3 (reg_addrI[3], execute, commitex, commitdt, retire, reg_dataR[3], hazard[3], reg_dataI[3]);
    regbypass bypss_reg2 (reg_addrI[2], execute, commitex, commitdt, retire, reg_dataR[2], hazard[2], reg_dataI[2]);
    regbypass bypss_reg1 (reg_addrI[1], execute, commitex, commitdt, retire, reg_dataR[1], hazard[1], reg_dataI[1]);
    regbypass bypss_reg0 (reg_addrI[0], execute, commitex, commitdt, retire, reg_dataR[0], hazard[0], reg_dataI[0]);
    hlbypass bypass_hilo (execute, commitex, commitdt, retire, hiR, loR, hilodataI[1], hilodataI[0]);
    /*
    cp0bypass bypass_cp01 (cp0_addrI[1], execute, commitex, commitdt, retire, cp0_dataR[1], _cp0_dataI[1]);
    cp0bypass bypass_cp00 (cp0_addrI[0], execute, commitex, commitdt, retire, cp0_dataR[0], _cp0_dataI[0]);
    */


    assign cp0_hazardI = 1'b0;
                         /*
                         execute.cp0_modify[1] | execute.cp0_modify[0] |
                         commitex.cp0_modify[1] | commitex.cp0_modify[0];
                         */
                         
    assign data_hazardI = (hazard[3] & dhazard_maskI[3]) | 
                          (hazard[2] & dhazard_maskI[2]) | 
                          (hazard[1] & dhazard_maskI[1]) | 
                          (hazard[0] & dhazard_maskI[0]) | 
                          cp0_hazardI;
    assign readyI = ~(hazard);                          
    
    //word_t [1: 0] _cp0_mask_and, _cp0_mask_or;
    //assign _cp0_mask_and = {cp0_mask_and[cp0_addrI[1]], cp0_mask_and[cp0_addrI[0]]};
    //assign _cp0_mask_or = {cp0_mask_or[cp0_addrI[1]], cp0_mask_or[cp0_addrI[0]]};
    
    //assign cp0_dataI[1] = (_cp0_dataI[1] & _cp0_mask_and[1]) | _cp0_mask_or[1];
    //assign cp0_dataI[0] = (_cp0_dataI[0] & _cp0_mask_and[0]) | _cp0_mask_or[0];
    //assign cp0_dataI = '0;

endmodule
