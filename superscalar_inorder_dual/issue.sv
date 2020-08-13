`include "mips.svh"

module issue(
        input clk, reset,
        input decode_data_t [1: 0] in,
        input logic [1: 0] hitD,
        output issue_data_t [1: 0] out,
        //pipeline
        output logic queue_ofI, 
        input logic data_hazardI,
        input logic stallI, flushI,
        input logic stallE, flushE,
        //control
        output logic [3: 0] dhazard_maskI,
        output creg_addr_t [3: 0] reg_addrI,
        input word_t [3: 0] reg_dataI,
        output logic [1: 0] hiloreadI, 
        input word_t [1: 0] hilodataI,
        //output creg_addr_t [1: 0] cp0_addrI,
        //input word_t [1: 0] cp0_dataI,
        input logic [3: 0] reg_readyI,
        // data_forward
        output logic first_cycpeE
    );

    logic [`ISSUE_QUEUE_SIZE - 1: 0] valid;
    decode_data_t [`ISSUE_QUEUE_SIZE - 1: 0] issue_queue;

    logic [`ISSUE_QUEUE_WIDTH - 1: 0] head, headplus1, headplus2;
    logic [`ISSUE_QUEUE_WIDTH - 1: 0] tail, tailplus1, tailplus2;
    assign headplus1 = head + `ISSUE_QUEUE_WIDTH'b001;
    assign headplus2 = head + `ISSUE_QUEUE_WIDTH'b010;
    assign tailplus1 = tail + `ISSUE_QUEUE_WIDTH'b001;
    assign tailplus2 = tail + `ISSUE_QUEUE_WIDTH'b010;
    
    logic queue_overflow;
    //assign queue_overflow = (hitD[1] && !free[0]) || (hitD[0] && !free[1]);
    assign queue_overflow = (hitD[1] && valid[tail]) || (hitD[0] && valid[tailplus1]);
    assign queue_ofI = queue_overflow;
    
    issue_data_t aI, bI;
    decode_data_t aD, bD;
    logic MM, RAW_hl, RAW_reg, BJa, BJb, BJ, enb, RAW;
    assign aD = (valid[head]) ? (issue_queue[head]) : ('0);
    assign bD = (valid[headplus1]) ? (issue_queue[headplus1]) : ('0);
    assign MM = (aD.instr.ctl.memtoreg || aD.instr.ctl.memwrite) && 
                (bD.instr.ctl.memtoreg || bD.instr.ctl.memwrite);
    assign RAW_hl = (aD.instr.ctl.hiwrite && bD.instr.ctl.hitoreg) || 
                    (aD.instr.ctl.lowrite && bD.instr.ctl.lotoreg);
    assign RAW_reg = (aD.instr.ctl.regwrite && aD.destreg == bD.srcrega) || 
                     (aD.instr.ctl.regwrite && aD.destreg == bD.srcregb);
    assign RAW = RAW_hl | RAW_reg;
    //read after write
                         
    assign BJa = aD.instr.ctl.branch || aD.instr.ctl.jump || aD.instr.ctl.jr;
    assign BJb = bD.instr.ctl.branch || bD.instr.ctl.jump || bD.instr.ctl.jr;
    //assign BJ = (BJa & free[6]) | (BJb);
    assign BJ = BJb;
    //issue together
    
    logic PRIV;
    assign PRIV = aD.instr.ctl.is_priv || bD.instr.ctl.is_priv;
    //an instr changes epc before ERET
    //an instr changes cause/status before exception 
    
    logic DMULT;
	assign DMULT = aD.instr.ctl.mul_div_r & bD.instr.ctl.mul_div_r;  
	
	logic LWLR;
	assign LWLR = aD.instr.ctl.regwrite && aD.destreg == bD.destreg && (bD.instr.op == LWL || bD.instr.op == LWR);   			   
    
    assign enb = ~(BJ || RAW || MM || PRIV || DMULT);
    //assign enb = 1'b0;

    logic [1: 0] issue_en;
    assign issue_en[1] = ~(BJa && ~valid[headplus1]) && (valid[head]);
    assign issue_en[0] = enb && (valid[headplus1]);
    //assign issue_en[1] = ~(BJa && ~valid[headplus1]) && (valid[head]);
    //assign issue_en[0] = (BJa) && (valid[headplus1]);
    
    
    issue_data_t [1: 0] out_;
    assign out_[1] = (issue_en[1]) ? (aI) : ('0);
    assign out_[0] = (issue_en[0]) ? (bI) : ('0);
    logic [`ISSUE_QUEUE_WIDTH - 1: 0] head_, tail_;

	
	logic [`ISSUE_QUEUE_SIZE - 1: 0] valid_;
    decode_data_t [`ISSUE_QUEUE_SIZE - 1: 0] issue_queue_;
	always_comb
		begin
			issue_queue_ = issue_queue;
			valid_ = valid;
			case (issue_en)
                2'b11: 
                    begin
                        issue_queue_[head] = '0;
                        issue_queue_[headplus1] = '0;
                        valid_[head] = '0;
                        valid_[headplus1] = '0;
                    end
                2'b10: 
                    begin
                        issue_queue_[head] = '0;
                        valid_[head] = '0;
                    end
                default: valid_ = valid;
            endcase
            case (issue_en)
                2'b11: head_ = headplus2;
                2'b10: head_ = headplus1;
                default: head_ = head;
            endcase
		end        
	
	logic [`ISSUE_QUEUE_SIZE - 1: 0] valid__;
    decode_data_t [`ISSUE_QUEUE_SIZE - 1: 0] issue_queue__;
	always_comb
		begin
			issue_queue__ = issue_queue;
			valid__ = valid;
			if (hitD[1]) 
                begin
                    issue_queue__[tail] = in[1];
                    valid__[tail] = 1'b1;
                end
            if (hitD[0])
            	begin
                	issue_queue__[((hitD[1]) ? (tailplus1) : (tail))] = in[0];
					valid__[((hitD[1]) ? (tailplus1) : (tail))] = 1'b1;
                end              
            case ({hitD[1], hitD[0]})
            	2'b11: tail_ = tailplus2;
				2'b10: tail_ = tailplus1;
                2'b01: tail_ = tailplus1;
                default: tail_ = tail;
            endcase
		end
	
	logic [`ISSUE_QUEUE_SIZE - 1: 0] valid___;
    decode_data_t [`ISSUE_QUEUE_SIZE - 1: 0] issue_queue___;
	always_comb
		begin
			issue_queue___ = issue_queue;
			valid___ = valid;
			case (issue_en)
                2'b11: 
                    begin
                        issue_queue___[head] = '0;
                        issue_queue___[headplus1] = '0;
                        valid___[head] = '0;
                        valid___[headplus1] = '0;
                    end
                2'b10: 
                    begin
                        issue_queue___[head] = '0;
                        valid___[head] = '0;
                    end
                default: valid___ = valid;
            endcase
			if (hitD[1]) 
                begin
                    issue_queue___[tail] = in[1];
                    valid___[tail] = 1'b1;
                end
            if (hitD[0])
            	begin
                	issue_queue___[((hitD[1]) ? (tailplus1) : (tail))] = in[0];
					valid___[((hitD[1]) ? (tailplus1) : (tail))] = 1'b1;
                end;
		end		                
    
    integer signal_issue, dual_issue;
    
    always_ff @(posedge clk) 
        begin
            if (~reset)
                begin
                    out <= '0;
                    head <= '0;
                    tail <= '0;
                    valid <= '0;
                    first_cycpeE <= 1'b1;
                    issue_queue <= '0;
                    signal_issue <= 0; 
                    dual_issue <= 0;
                end
            else
                begin
                	if (flushE) 
                		begin
                			out <= '0;
                			first_cycpeE <= 1'b1;
                		end
                    else
                    	begin
							if (~stallE)
								begin
									out <= out_;
									first_cycpeE <= 1'b1;
									
									dual_issue <= (issue_en == 2'b11) ? (dual_issue + 1) : (dual_issue);
									signal_issue <= (issue_en == 2'b10) ? (signal_issue + 1) : (signal_issue);
								end 
							else 
								first_cycpeE <= 1'b0;
						end
                	
                    if (flushI)
                    	begin
                    		head <= '0;
                    		tail <= '0;
                    		valid <= '0;
                    	end
                	else
                		begin
                			case ({~queue_overflow, ~stallI})
                				2'b11:
                					begin
                						head <= head_;
                						tail <= tail_;
                						issue_queue <= issue_queue___;
                						valid <= valid___;
                					end
                				2'b01:
                					begin
                						head <= head_;
                						issue_queue <= issue_queue_;
                						valid <= valid_;
                					end
                				2'b10:
                					begin
                						tail <= tail_;
                						issue_queue <= issue_queue__;
                						valid <= valid__;
                					end
                				default:
                					valid <= valid;
                			endcase
                		end
                end                
        end

    word_t hi, lo;
    assign dhazard_maskI = {1'b1 & ~aD.instr.ctl.delayen, 1'b1 & ~aD.instr.ctl.delayen, 
                            issue_en[0] & ~bD.instr.ctl.delayen, issue_en[0] & ~bD.instr.ctl.delayen};
    assign reg_addrI = {aD.srcrega, aD.srcregb, bD.srcrega, bD.srcregb}; 
    assign hiloreadI = {aD.instr.ctl.hitoreg || bD.instr.ctl.hitoreg, 
                        aD.instr.ctl.lotoreg || bD.instr.ctl.lotoreg};
    assign {hi, lo} = hilodataI;
    //assign cp0_addrI = {aD.cp0_addr, bD.cp0_addr};

    decode_to_issue_t decode_to_issue_t1(aD, 
                                         hi, lo, 
                                         reg_dataI[3], reg_dataI[2], reg_readyI[3], reg_readyI[2], 
                                         //cp0_dataI[1], 
                                         aI, 
                                         'b0, 'b0);
    decode_to_issue_t decode_to_issue_t0(bD, 
                                         hi, lo, 
                                         reg_dataI[1], reg_dataI[0], reg_readyI[1], reg_readyI[0], 
                                         //cp0_dataI[0], 
                                         bI, 
                                         BJa, aD.instr.ctl.is_link);

endmodule
 