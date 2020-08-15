`include "mips.svh"

module pcfetch(
        input logic clk, reset, stall, flush,
        input word_t pc_new, 
        output word_t addr,
        output word_t pc, pcplus4, pcplus8,
        input logic inst_ibus_addr_ok,
        output logic inst_ibus_req, finish_pc,
        //to fetch control
        output word_t [1: 0] pc_predictF,
        input bpb_result_t [1: 0] destpc_predictF_in,
        output bpb_result_t [1: 0] destpc_predictF_out,
        input tu_op_resp_t tu_op_resp,
        output tlb_invalid, tlb_refill
    );    

    word_t pc_;                      
    logic finish_his_, finish_his;    
    logic inst_ibus_req_normal_, first_cycle_, inst_ibus_req_normal, first_cycle, fc_mask;
    assign fc_mask = first_cycle & tu_op_resp.i_mapped;

    always_comb 
        begin
            pc_ = pc;
            finish_his_ = finish_his;
            inst_ibus_req_normal_ = inst_ibus_req_normal;
            first_cycle_ = first_cycle;
            if (~reset)
                begin
                    pc_ = 32'Hbfc00000;
                    finish_his_ = 1'b0;
                    //inst_ibus_req <= 1'b1;
                    inst_ibus_req_normal_ = 1'b1;
                    first_cycle_ = 1'b1;
                end
            else
                begin
                    if (finish_pc) 
                        inst_ibus_req_normal_ = 1'b0;
                    if (inst_ibus_addr_ok & ~fc_mask)
                        finish_his_ = 1'b1; 
                        
                    if (~stall || flush)
                        begin
                            pc_ = pc_new;
                            finish_his_ = 1'b0;
                            //inst_ibus_req = 1'b1;
                            inst_ibus_req_normal_ = 1'b1;
                            first_cycle_ = 1'b1;
                        end
                     else
                         begin
                             if (~finish_pc)
                                begin
                                     //inst_ibus_req = 1'b1;
                                     inst_ibus_req_normal_ = 1'b1;
                                 end       
                            first_cycle_ = 1'b0;
                         end  
                end
        end

    always_ff @(posedge clk) 
        begin
            pc <= pc_;
            finish_his <= finish_his_;
            inst_ibus_req_normal <= inst_ibus_req_normal_;
            first_cycle <= first_cycle_;
        end                      

    assign finish_pc = (finish_his | inst_ibus_addr_ok | (tlb_invalid | tlb_refill)) & (~fc_mask);
    assign inst_ibus_req = inst_ibus_req_normal & ~(tlb_invalid | tlb_refill) & ~fc_mask;
    
    assign addr = pc;
    assign pcplus4 = pc + 5'b00100;
    assign pcplus8 = pc + 5'b01000;
    assign tlb_invalid = tu_op_resp.i_tlb_invalid;
    assign tlb_refill = tu_op_resp.i_tlb_refill;
                                      
    assign pc_predictF = {pc, pcplus4};
    assign destpc_predictF_out = destpc_predictF_in;
    
endmodule
