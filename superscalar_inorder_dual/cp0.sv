`include "mips.svh"
`include "tu.svh"

module cp0(
        input logic clk, reset,
        (*mark_debug = "true"*) input rf_w_t [1: 0] cwrite,//write
        (*mark_debug = "true"*) input logic[1:0][2:0] sel,
        input creg_addr_t [1: 0] ra,
        output word_t [1: 0] rd,
        //read or write
        input logic is_eret,
        //commit or fetch, updata pc
        output logic timer_interrupt,
        //commit
        input exception_t exception,
        //exception
        output cp0_regs_t cp0_data,
        //bypass
        input tu_op_resp_t tlb_resp,
        (*mark_debug = "true"*) input logic is_tlbr,
        (*mark_debug = "true"*) input logic is_tlbp,
        /*
        output cp0_entryhi_t cp0_entryhi,
        output cp0_entrylo_t cp0_entrylo0, cp0_entrylo1,
        output cp0_index_t cp0_index,
        */
        output logic k0_uncached 
    );

    cp0_regs_t cp0, cp0_new;
    word_t wd;
    always_ff @(posedge clk) begin
        if (~reset) begin
            cp0 <= `CP0_INIT;
        end
        else begin
            cp0 <= cp0_new;
        end
    end

    logic count_switch;

    always_ff @(posedge clk) begin
        if (~reset) begin
            count_switch <= 1'b1;
        end else begin
            count_switch <= ~count_switch;
        end
    end
    // read
    always_comb begin
        if ( sel[1] == 3'b1 && ra[1] == 5'd16 ) begin
            rd[1] = cp0.config_1;
        end else case (ra[1])
            5'd0:   rd[1] = cp0.index;
            5'd1:   rd[1] = cp0.random;
            5'd2:   rd[1] = cp0.entrylo0;
            5'd3:   rd[1] = cp0.entrylo1;
            5'd4:   rd[1] = cp0.context_;
            5'd6:   rd[1] = cp0.wired;
            5'd8:   rd[1] = cp0.badvaddr;
            5'd9:   rd[1] = cp0.count;
            5'd10:  rd[1] = cp0.entryhi;
            5'd11:  rd[1] = cp0.compare;
            5'd12:  rd[1] = cp0.status;
            5'd13:  rd[1] = cp0.cause;
            5'd14:  rd[1] = cp0.epc;
            5'd15:  rd[1] = cp0.prid;
            5'd16:  rd[1] = cp0.config_;
            default:rd[1] = '0;
        endcase
    end
    always_comb begin
        if ( sel[0] == 3'b1 && ra[0] == 5'd16 ) begin
            rd[0] = cp0.config_1;
        end else case (ra[0])
            5'd0:   rd[0] = cp0.index;
            5'd1:   rd[0] = cp0.random;
            5'd2:   rd[0] = cp0.entrylo0;
            5'd3:   rd[0] = cp0.entrylo1;
            5'd4:   rd[0] = cp0.context_;
            5'd6:   rd[0] = cp0.wired;
            5'd8:   rd[0] = cp0.badvaddr;
            5'd9:   rd[0] = cp0.count;
            5'd10:  rd[0] = cp0.entryhi;
            5'd11:  rd[0] = cp0.compare;
            5'd12:  rd[0] = cp0.status;
            5'd13:  rd[0] = cp0.cause;
            5'd14:  rd[0] = cp0.epc;
            5'd15:  rd[0] = cp0.prid;
            5'd16:  rd[0] = cp0.config_;
            default:rd[0] = '0;
        endcase
    end
    always_ff @(posedge clk) begin
        if (~reset) begin
            timer_interrupt <= 1'b0;
        end else if (cp0.count == cp0.compare - 1) begin
            timer_interrupt <= 1'b1;
        end else if ((cwrite[1].wen & cwrite[1].addr == 5'd11) | (cwrite[0].wen & cwrite[0].addr == 5'd11)) begin
            timer_interrupt <= 1'b0;
        end
    end
    // update cp0 registers
    always_comb begin
        cp0_new = cp0;

        cp0_new.count = cp0_new.count + count_switch;
        
        // write
        if (cwrite[1].wen && sel[1] == 3'd0) begin
            case (cwrite[1].addr)
                5'd0:   cp0_new.index.index = cwrite[1].wd[4:0];
                5'd2:   cp0_new.entrylo0[PABITS-7:0] = cwrite[1].wd[PABITS-7:0];
                5'd3:   cp0_new.entrylo1[PABITS-7:0] = cwrite[1].wd[PABITS-7:0];
                5'd4:   cp0_new.context_.ptebase = cwrite[1].wd[31:23];
                5'd6:   cp0_new.wired.wired = cwrite[1].wd[TLB_INDEX-1:0];
                5'd9:   cp0_new.count   = cwrite[1].wd;
                5'd10: 
                begin
                        cp0_new.entryhi.vpn2 = cwrite[1].wd[31:13];
                        cp0_new.entryhi.asid = cwrite[1].wd[7:0];
                end 
                5'd11:  cp0_new.compare = cwrite[1].wd;
                5'd12:
                begin
                        cp0_new.status.IM = cwrite[1].wd[15:8];
                        cp0_new.status.EXL = cwrite[1].wd[1];
                        cp0_new.status.IE = cwrite[1].wd[0];
                end
                5'd13:  cp0_new.cause.IP[1:0] = cwrite[1].wd[9:8];
                5'd14:  cp0_new.epc = cwrite[1].wd;
                5'd16: 
                begin
                        cp0_new.config_[30:25] = cwrite[1].wd[30:25];
                        cp0_new.config_.K0 = cwrite[1].wd[2:0];
                end
                default: ;
            endcase
        end
        if (cwrite[0].wen && sel[0] == 3'd0) begin
            case (cwrite[0].addr)
                5'd0:   cp0_new.index.index = cwrite[0].wd[4:0];
                5'd2:   cp0_new.entrylo0[PABITS-7:0] = cwrite[0].wd[PABITS-7:0];
                5'd3:   cp0_new.entrylo1[PABITS-7:0] = cwrite[0].wd[PABITS-7:0];
                5'd4:   cp0_new.context_.ptebase = cwrite[0].wd[31:23];
                5'd6:   cp0_new.wired.wired = cwrite[0].wd[TLB_INDEX-1:0];
                5'd9:   cp0_new.count   = cwrite[0].wd;
                5'd10: 
                begin
                        cp0_new.entryhi.vpn2 = cwrite[0].wd[31:13];
                        cp0_new.entryhi.asid = cwrite[0].wd[7:0];
                end 
                5'd11:  cp0_new.compare = cwrite[0].wd;
                5'd02:
                begin
                        cp0_new.status.IM = cwrite[0].wd[15:8];
                        cp0_new.status.EXL = cwrite[0].wd[1];
                        cp0_new.status.IE = cwrite[0].wd[0];
                end
                5'd13:  cp0_new.cause.IP[1:0] = cwrite[0].wd[9:8];
                5'd14:  cp0_new.epc = cwrite[0].wd;
                5'd16: 
                begin
                        cp0_new.config_[30:25] = cwrite[0].wd[30:25];
                        cp0_new.config_.K0 = cwrite[0].wd[2:0];
                end
                default: ;
            endcase
        end

        // tlb
        if (is_tlbr) begin
            cp0_new.entryhi = tlb_resp.entryhi;
            cp0_new.entrylo0 = tlb_resp.entrylo0;
            cp0_new.entrylo1 = tlb_resp.entrylo1;
        end 
        if (is_tlbp) begin
            cp0_new.index = tlb_resp.index;
        end
        // exception
        if (exception.valid) begin
            if (~cp0.status.EXL) begin
                if (exception.in_delay_slot) begin
                    cp0_new.cause.BD = 1'b1;
                    cp0_new.epc = exception.pc - 32'd4;
                end else begin
                    cp0_new.cause.BD = 1'b0;
                    cp0_new.epc = exception.pc;
                end
            end

            cp0_new.cause.exccode = exception.code;

            cp0_new.status.EXL = 1'b1;
            if (exception.code == `CODE_ADEL || exception.code == `CODE_ADES) begin
                cp0_new.badvaddr = exception.badvaddr;
            end

            // TLB
            if (exception.code == `CODE_TLBL || exception.code == `CODE_MOD || exception.code == `CODE_TLBS) begin
                cp0_new.badvaddr = exception.badvaddr;
				cp0_new.context_.badvpn2 = exception.badvaddr[31:13]; // ??
				cp0_new.entryhi.vpn2 = exception.badvaddr[31:13];  
            end
        end

        // eret
        if (is_eret) begin
            if (cp0.status.ERL) begin
                cp0_new.status.ERL = 1'b0;
            end else begin
                cp0_new.status.EXL = 1'b0;
            end
        end
    end

    assign cp0_data = cp0;
    /*
    assign cp0_status = cp0.status;
    assign cp0_cause = cp0.cause;
    assign cp0_epc = cp0.epc;
    assign cp0_entryhi = cp0.entryhi;
    assign cp0_entrylo0 = cp0.entrylo0;
    assign cp0_entrylo1 = co0.entrylo1;
    assign cp0_index = cp0_index;
    */
    assign k0_uncached = cp0.config_.K0 == 3'b011;
endmodule