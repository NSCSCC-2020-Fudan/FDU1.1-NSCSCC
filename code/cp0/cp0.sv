`include "mips.svh"

module cp0(
    input logic clk, reset,
    cp0_intf.cp0 ports,
    exception_intf.cp0 excep,
    pcselect_intf.cp0 pcselect
);
    logic is_eret;
    cp0_regs_t cp0, cp0_new;
    word_t wd;
    rf_w_t cwrite; 
    exception_t exception;
    creg_addr_t ra;
    word_t rd;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0 <= `CP0_INIT;
        end
        else begin
            cp0 <= cp0_new;
        end
    end

    logic count_switch;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            count_switch <= 1'b0;
        end else begin
            count_switch <= ~count_switch;
        end
    end
    // read
    always_comb begin
        case (ra)
            5'd8:   rd = cp0.badvaddr;
            5'd9:   rd = cp0.count;
            5'd12:  rd = cp0.status;
            5'd13:  rd = cp0.cause;
            5'd14:  rd = cp0.epc;
            5'd16:  rd = cp0.config_;
            default:rd = '0;
        endcase
    end
    
    // update cp0 registers
    always_comb begin
        cp0_new = cp0;
        
        cp0_new.count = cp0_new.count + count_switch;
        if (reset) begin
            ports.timer_interrupt = 1'b0;
        end else if (cp0_new.count == cp0_new.compare) begin
            ports.timer_interrupt = 1'b1;
        end else if (cwrite.wen & cwrite.addr == 5'd11) begin
            ports.timer_interrupt = 1'b0;
        end
        // write
        if (cwrite.wen) begin
            case (cwrite.addr)
                5'd9:   cp0_new.count   = cwrite.wd;
                5'd11:  cp0_new.compare = cwrite.wd;
                5'd12:  
                begin
                        cp0_new.status.IM = cwrite.wd[15:8];
                        cp0_new.status.EXL = cwrite.wd[1];
                        cp0_new.status.IE = cwrite.wd[0];
                end
                5'd13:  cp0_new.cause.IP[7:2] = cwrite.wd[15:10];
                5'd14:  cp0_new.epc = cwrite.wd;
                default: ;
            endcase
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
        end

        if (is_eret) begin
            if (cp0.status.ERL) begin
                cp0_new.status.ERL = 1'b0;
            end else begin
                cp0_new.status.EXL = 1'b0;
            end
            // llbit = 1'b0;
        end
    end
    assign cwrite = ports.cwrite;
    assign ports.cp0_data = cp0;
    assign is_eret = ports.is_eret;
    assign exception = excep.exception;
    assign ra = ports.ra;
    assign ports.rd = rd;
    assign excep.cp0_data = cp0;
    assign pcselect.is_eret = is_eret;
    assign pcselect.epc = cp0.epc;
endmodule