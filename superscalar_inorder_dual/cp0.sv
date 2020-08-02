`include "mips.svh"

module cp0(
        input logic clk, reset,
        input rf_w_t [1: 0] cwrite,//write
        input creg_addr_t [1: 0] ra,
        output word_t [1: 0] rd,
        //read or write
        input logic is_eret,
        //commit or fetch, updata pc
        output logic timer_interrupt,
        //commit
        input exception_t exception,
        //exception
        output cp0_cause_t cp0_cause,
        output cp0_status_t cp0_status,
        output word_t cp0_epc
        //bypass
    );

    cp0_regs_t cp0, cp0_new;
    word_t wd;
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
            count_switch <= 1'b1;
        end else begin
            count_switch <= ~count_switch;
        end
    end
    // read
    always_comb begin
        case (ra[1])
            5'd8:   rd[1] = cp0.badvaddr;
            5'd9:   rd[1] = cp0.count;
            5'd12:  rd[1] = cp0.status;
            5'd13:  rd[1] = cp0.cause;
            5'd14:  rd[1] = cp0.epc;
            5'd16:  rd[1] = cp0.config_;
            default:rd[1] = '0;
        endcase
    end
    always_comb begin
        case (ra[0])
            5'd8:   rd[0] = cp0.badvaddr;
            5'd9:   rd[0] = cp0.count;
            5'd12:  rd[0] = cp0.status;
            5'd13:  rd[0] = cp0.cause;
            5'd14:  rd[0] = cp0.epc;
            5'd16:  rd[0] = cp0.config_;
            default:rd[0] = '0;
        endcase
    end

    // update cp0 registers
    always_comb begin
        cp0_new = cp0;

        cp0_new.count = cp0_new.count + count_switch;
        if (reset) begin
            timer_interrupt = 1'b0;
        end else if (cp0_new.count == cp0_new.compare - 1) begin
            timer_interrupt = 1'b1;
        end else if ((cwrite[1].wen & cwrite[1].addr == 5'd11) | (cwrite[0].wen & cwrite[0].addr == 5'd11)) begin
            timer_interrupt = 1'b0;
        end
        // write
        if (cwrite[1].wen) begin
            case (cwrite[1].addr)
                5'd9:   cp0_new.count   = cwrite[1].wd;
                5'd11:  cp0_new.compare = cwrite[1].wd;
                5'd12:
                begin
                        cp0_new.status.IM = cwrite[1].wd[15:8];
                        cp0_new.status.EXL = cwrite[1].wd[1];
                        cp0_new.status.IE = cwrite[1].wd[0];
                end
                5'd13:  cp0_new.cause.IP[1:0] = cwrite[1].wd[9:8];
                5'd14:  cp0_new.epc = cwrite[1].wd;
                default: ;
            endcase
        end
        if (cwrite[0].wen) begin
            case (cwrite[0].addr)
                5'd9:   cp0_new.count   = cwrite[0].wd;
                5'd11:  cp0_new.compare = cwrite[0].wd;
                5'd12:
                begin
                        cp0_new.status.IM = cwrite[0].wd[15:8];
                        cp0_new.status.EXL = cwrite[0].wd[1];
                        cp0_new.status.IE = cwrite[0].wd[0];
                end
                5'd13:  cp0_new.cause.IP[1:0] = cwrite[0].wd[9:8];
                5'd14:  cp0_new.epc = cwrite[0].wd;
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

    assign cp0_data = cp0;
    assign cp0_status = cp0.status;
    assign cp0_cause = cp0.cause;
    assign cp0_epc = cp0.epc;

endmodule