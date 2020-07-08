`include "mips.svh"

module CP0(
    input logic clk, reset,

    // read
    input cp0_addr_t ra,
    output word_t rd,

    // write
    input logic we,
    input cp0_addr_t wa,
    input word_t wd,

    // exception
    input exception_t exception,
    input logic eret,

    output cp0_regs_t cp0
);
    CP0_REGS cp0_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0 <= `CPO_INIT;
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

        // write
        if (we) begin
            case (wa)
                5'd9:   cp0_new.count   = wd;
                5'd11:  cp0_new.compare = wd;
                5'd12:  
                begin
                        cp0_new.status.IM = wd[15:8];
                        cp0_new.status.EXL = wd[1];
                        cp0_new.status.IE = wd[0];
                end
                5'd13:  cp0_new.cause.IP[7:2] = wd[15:10];
                5'd14:  cp0_new.epc = wd;
                default: ;
            endcase
        end

        // exception
        if (exception.valid) begin
            if (~cp0.status.EXL) begin
                if (exception.in_delay_slot) begin
                    cp0_new.status.bd = 1'b1;
                    cp0_new.epc = exception.pc - 32'd4;
                end else begin
                    cp0_new.status.bd = 1'b0;
                    cp0_new.epc = exception.pc;
                end
            end

            cp0_new.cause.exccode = exception.code;

            cp0_new.status.EXL = 1'b1;
            if (exception.code == `CODE_ADEL || exception.code == `CODE_ADES) begin
                cp0_new.badvaddr = exception.badvaddr;
            end
        end

        if (eret) begin
            if (cp0.status.ERL) begin
                cp0_new.status.ERL = 1'b0;
            end else begin
                cp0_new.status.EXL = 1'b0;
            end
            // llbit = 1'b0;
        end
    end

endmodule