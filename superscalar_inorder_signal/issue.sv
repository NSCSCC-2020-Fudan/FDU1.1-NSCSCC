`include "mips.svh"

module issue(
        input clk, reset,
        input decode_data_t [1: 0] in,
        input logic [1: 0] hitD,
        output issue_data_t [1: 0] out,
        //pipeline
        output logic queue_ofI, data_hazardI,
        input logic stallI, flushI,
        input logic stallE, flushE,
        //control
        output creg_addr_t [3: 0] reg_addrI,
        input word_t [3: 0] reg_dataI,
        output logic [1: 0] hiloreadI, 
        input word_t [1: 0] hilodataI,
        output creg_addr_t [1: 0] cp0_addrI,
        input word_t [1: 0] cp0_dataI,
        input cp0_status_t cp0_statusI,
        input cp0_cause_t cp0_causeI,
        input word_t cp0_epcI,
        // data_forward
        output logic mul_timeok, div_timeok
    );

    logic [7: 0] free, valid;
    decode_data_t [7: 0] issue_queue;

    logic [2: 0] head, headplus1, headplus2;
    logic [2: 0] tail, tailplus1, tailplus2;
    assign headplus1 = head + 3'b001;
    assign headplus2 = head + 3'b010;
    assign tailplus1 = tail + 3'b001;
    assign tailplus2 = tail + 3'b010;
    
    logic queue_overflow;
    //assign queue_overflow = (hitD[1] && !free[0]) || (hitD[0] && !free[1]);
    assign queue_overflow = (hitD[1] && valid[tail]) || (hitD[0] && valid[tailplus1]);
    assign queue_ofI = queue_overflow;
    
    issue_data_t aI, bI;
    decode_data_t aD, bD;
    logic MM, RAW_hl, RAW_reg, BJa, BJb, BJ, enb, RAW;
    assign aD = issue_queue[head];
    assign bD = issue_queue[headplus1];
    assign MM = (aD.instr.ctl.memtoreg || aD.instr.ctl.memwrite) && 
                (bD.instr.ctl.memtoreg || bD.instr.ctl.memwrite);
    assign RAW_hl = (aD.instr.ctl.hiwrite && bD.instr.ctl.hitoreg) || 
                    (aD.instr.ctl.lowrite && bD.instr.ctl.lotoreg);
    assign RAW_reg = (aD.instr.ctl.regwrite && aD.destreg == bD.srcrega) || 
                     (aD.instr.ctl.regwrite && aD.destreg == bD.srcregb);
    assign RAW_cp0 = (aD.instr.ctl.cp0write && aD.cp0_addr == bD.cp0_addr && bD.instr.ctl.cp0toreg); 
    assign RAW = RAW_hl | RAW_reg | RAW_cp0;
    //read after write
                         
    assign BJa = aD.instr.ctl.branch || aD.instr.ctl.jump || aD.instr.ctl.jr;
    assign BJb = bD.instr.ctl.branch || bD.instr.ctl.jump || bD.instr.ctl.jr;
    //assign BJ = (BJa & free[6]) | (BJb);
    assign BJ = BJb;
    //issue together
    
    logic ERETb, CAUSEa, STATUSa, PRIV;
    assign ERETb = (bD.instr.op == ERET);
    assign CAUSEa = (aD.instr.ctl.cp0write && aD.cp0_addr == 5'd12);
    assign STATUSa = (aD.instr.ctl.cp0write && aD.cp0_addr == 5'd13);
    assign PRIV = ERETb || CAUSEa || STATUSa;
    //an instr changes epc before ERET
    //an instr changes cause/status before exception 
    
    assign enb = ~(BJ || RAW || MM || PRIV);
    //assign enb = 1'b0;

    logic [1: 0] issue_en;
    assign issue_en[1] = ~(BJa && ~valid[headplus1]) && (valid[head]);
    assign issue_en[0] = enb && (valid[headplus1]);
    //assign issue_en[1] = ~(BJa && ~valid[headplus1]) && (valid[head]);
    //assign issue_en[0] = (BJa) && (valid[headplus1]);
    
    logic [`MUL_DELAY - 1: 0] MULU_TIMER;
    logic [`DIV_DELAY - 1: 0] DIVU_TIMER;
    assign mul_timeok = MULU_TIMER[0];
    assign div_timeok = DIVU_TIMER[0];
    
    always_ff @(posedge clk, posedge reset) 
        begin
            if (reset)
                begin
                    out[1] <= '0;
                    out[0] <= '0;
                    head = '0;
                    tail = '0;
                    valid = {(8){1'b0}};
                    issue_queue = '0;
                    MULU_TIMER <= {(`MUL_DELAY){1'b1}};
                    DIVU_TIMER <= {(`DIV_DELAY){1'b1}};
                end
            else
                begin
                    if (flushE)
                        begin
                            out <= '0;
                            MULU_TIMER <= {(`MUL_DELAY){1'b1}};
                            DIVU_TIMER <= {(`DIV_DELAY){1'b1}};
                        end
                    else
                        if (~stallE)
                            begin
                                out[1] <= (issue_en[1]) ? (aI) : ('0);
                                out[0] <= (issue_en[0]) ? (bI) : ('0);
                                MULU_TIMER <= {1'b1, {(`MUL_DELAY - 1){1'b0}}};
                                DIVU_TIMER <= {1'b1, {(`DIV_DELAY - 1){1'b0}}}; 
                            end
                        else
                            begin
                                MULU_TIMER <= {1'b1, MULU_TIMER[`MUL_DELAY - 1: 1]};
                                DIVU_TIMER <= {1'b1, DIVU_TIMER[`DIV_DELAY - 1: 1]};
                            end
                            
                    if (~stallI)
                        begin
                            case (issue_en)
                                2'b11: 
                                    begin
                                        issue_queue[head] = '0;
                                        issue_queue[headplus1] = '0;
                                        //free =  {free[5: 0], 2'b11};
                                        valid[head] = '0;
                                        valid[headplus1] = '0;
                                    end
                                2'b10: 
                                    begin
                                        issue_queue[head] = '0;
                                        //free =  {free[6: 0], 1'b1};
                                        valid[head] = '0;
                                    end
                                default: valid = valid;
                            endcase
                            
                            case (issue_en)
                                2'b11: head = headplus2;
                                2'b10: head = headplus1;
                                default: head = head;
                            endcase
                        end
                                                
                    if (flushI)
                        begin
                            head = '0;
                            tail = '0;
                            valid = {(8){1'b0}};
                            issue_queue = '0;
                        end
                    else
                        if (~queue_overflow) 
                            begin
                                if (hitD[1]) 
                                    begin
                                        issue_queue[tail] = in[1];
                                        valid[tail] = 1'b1;
                                        //free = {1'b0, free[7: 1]};
                                    end
                                if (hitD[0])
                                    begin
                                        issue_queue[((hitD[1]) ? (tailplus1) : (tail))] = in[0];
                                        valid[((hitD[1]) ? (tailplus1) : (tail))] = 1'b1;
                                        //free = {1'b0, free[7: 1]};
                                    end              
                                case ({hitD[1], hitD[0]})
                                    2'b11: tail = tailplus2;
                                    2'b10: tail = tailplus1;
                                    2'b01: tail = tailplus1;
                                    default: tail = tail;
                                endcase
                            end
                end                
        end

    word_t hi, lo;
    assign reg_addrI = {aD.srcrega, aD.srcregb, bD.srcrega, bD.srcregb}; 
    assign hiloreadI = {aD.instr.ctl.hitoreg || bD.instr.ctl.hitoreg, 
                        aD.instr.ctl.lotoreg || bD.instr.ctl.lotoreg};
    assign {hi, lo} = hilodataI;
    assign cp0_addrI = {aD.cp0_addr, bD.cp0_addr};

    decode_to_issue_t decode_to_issue_t1(aD, hi, lo, reg_dataI[3], reg_dataI[2], cp0_dataI[1], cp0_statusI, cp0_causeI, cp0_epcI, aI, 'b0, 'b0);
    decode_to_issue_t decode_to_issue_t0(bD, hi, lo, reg_dataI[1], reg_dataI[0], cp0_dataI[0], cp0_statusI, cp0_causeI, cp0_epcI, bI, BJa, aD.instr.ctl.is_link);

endmodule 