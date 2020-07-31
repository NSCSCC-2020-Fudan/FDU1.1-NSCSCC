`include "mips.svh"

module pcfetch(
        input logic clk, reset, stall, flush,
        input word_t pc_new, 
        output word_t addr,
        output word_t pc, pcplus4, pcplus8,
        input logic inst_ibus_addr_ok,
        output logic inst_ibus_req, finish_pc
    );    
                      
    logic finish_his;                             
    always_ff @(posedge clk, posedge reset) 
        begin
            if (reset)
                begin
                    pc <= 32'Hbfc00000;
                    finish_his <= 1'b0;
                    inst_ibus_req <= 1'b1;
                end
            else
                begin
                    if (inst_ibus_addr_ok)
                        begin
                            inst_ibus_req = 1'b0;
                            finish_his = 1'b1; 
                        end
                        
                    if (~stall || flush)
                        begin
                            pc <= pc_new;
                            finish_his = 1'b0;
                            inst_ibus_req = 1'b1;
                        end
                     else
                        if (~finish_pc)
                            inst_ibus_req = 1'b1;       
                end
        end                      
    assign finish_pc = finish_his | inst_ibus_addr_ok;
    //assign inst_ibus_req = ~finish_pc;
    
    assign addr = pc;
    assign pcplus4 = pc + 5'b00100;
    assign pcplus8 = pc + 5'b01000;
    
endmodule
