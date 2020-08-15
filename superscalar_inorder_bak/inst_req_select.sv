`include "tu.svh"
`include "mips.svh"
`include "instr_bus.svh"
`include "data_bus.svh"

module inst_req_select(
        input logic clk, reset, stall, flush,
        input logic [1: 0] icache_op,
        input logic finishF,

        input ibus_req_t  imem_reqF, imem_reqC,
        output ibus_req_t imem_req,
        output ibus_resp_t imem_respF, imem_respC,
        input ibus_resp_t imem_resp,
        
        output tu_op_resp_t tu_op_respF, tu_op_respC,
        input tu_op_resp_t tu_op_resp
    );
    
    logic finishF_his, first_cycle;
    logic finishF_his_, first_cycle_;
    always_comb 
        begin
            finishF_his_ = finishF_his;
            first_cycle_ = first_cycle;
            if (~reset || flush || ~stall)
                begin
                    finishF_his_ = 1'b0;
                    first_cycle_ = 1'b1;
                end
            else
                begin   
                    if (finishF_his)
                        first_cycle_ = 1'b0;
                    if (finishF)
                        finishF_his_ = 1'b1;
                end
        end
    always_ff @(posedge clk)
        begin
            first_cycle <= first_cycle_;
            finishF_his <= finishF_his_;
        end

    logic mask, selectC;
    assign mask = (icache_op[1]) ? (first_cycle) : (1'b0);

    always_comb 
        begin
            if (icache_op[1])
                imem_req = (~finishF_his) ? (imem_reqF) : (
                           (first_cycle)  ? ('0)        : (imem_reqC));
            else
                imem_req = imem_reqF;
        end

    always_comb 
        begin
            imem_respC = imem_resp;
            imem_respF = imem_resp;
            if (icache_op[1])
                begin
                    imem_respC.addr_ok = (mask)         ? (1'b0) : (imem_resp.addr_ok);
                    imem_respF.addr_ok = (finishF_his)  ? (1'b0) : (imem_resp.addr_ok);
                end
            else 
                imem_respC.addr_ok = 1'b0;
            
            if (icache_op[0])
                imem_respF.data_ok = 1'b0;
            else 
                imem_respC.data_ok = 1'b0;
        end

    always_comb 
        begin
            tu_op_respC = tu_op_resp;
            tu_op_respF = '0;
            if (icache_op[1]) 
                begin
                    tu_op_respC.i_tlb_invalid =  (mask) ? (1'b0) : (tu_op_resp.i_tlb_invalid);
                    tu_op_respC.i_tlb_modified = (mask) ? (1'b0) : (tu_op_resp.i_tlb_modified);
                    tu_op_respC.i_tlb_refill =   (mask) ? (1'b0) : (tu_op_resp.i_tlb_refill);
                    tu_op_respC.i_mapped =       (mask) ? (1'b0) : (tu_op_resp.i_mapped);

                    tu_op_respF.i_tlb_invalid =  (finishF_his) ? (1'b0) : (tu_op_resp.i_tlb_invalid);
                    tu_op_respF.i_tlb_modified = (finishF_his) ? (1'b0) : (tu_op_resp.i_tlb_modified);
                    tu_op_respF.i_tlb_refill =   (finishF_his) ? (1'b0) : (tu_op_resp.i_tlb_refill);
                    tu_op_respF.i_mapped =       (finishF_his) ? (1'b0) : (tu_op_resp.i_mapped);
                end
            else
                begin
                    tu_op_respF.i_tlb_invalid =  tu_op_resp.i_tlb_invalid;
                    tu_op_respF.i_tlb_modified = tu_op_resp.i_tlb_modified;
                    tu_op_respF.i_tlb_refill =   tu_op_resp.i_tlb_refill;
                    tu_op_respF.i_mapped =       tu_op_resp.i_mapped;

                    tu_op_respC.i_tlb_invalid =  1'b0;
                    tu_op_respC.i_tlb_modified = 1'b0;
                    tu_op_respC.i_tlb_refill =   1'b0;
                    tu_op_respC.i_mapped =       1'b0;
                end
        end
        
endmodule