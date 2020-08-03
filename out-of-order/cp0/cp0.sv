`include "interface.svh"

module cp0
    import common::*;
    import exception_pkg::*;
    import cp0_pkg::*;(
    input logic clk, resetn,
    exception_intf.cp0 excep,
    pcselect_intf.cp0 pcselect,
    payloadRAM_intf.cp0 payloadRAM,
    retire_intf.cp0 retire
);
    logic is_eret;
    cp0_regs_t cp0, cp0_new;
    word_t wd;
    rf_w_t cwrite; 
    exception_t exception;
    creg_addr_t ra;
    word_t rd;
    always_ff @(posedge clk) begin
        if (~resetn) begin
            cp0 <= `CP0_INIT;
        end
        else begin
            cp0 <= cp0_new;
        end
    end

    logic count_switch;

    always_ff @(posedge clk) begin
        if (~resetn) begin
            count_switch <= 1'b1;
        end else begin
            count_switch <= ~count_switch;
        end
    end
    always_ff @(posedge clk) begin
        if (~resetn) begin
            excep.timer_interrupt <= 1'b0;
        end else if (cp0.count == cp0.compare - 1) begin
            excep.timer_interrupt <= 1'b1;
        end else if (cwrite.wen & cwrite.addr == 5'd11) begin
            excep.timer_interrupt <= 1'b0;
        end
    end
    // read
    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            case (payloadRAM.creg1[i][4:0])
                5'd8:   payloadRAM.cp01[i] = cp0.badvaddr;
                5'd9:   payloadRAM.cp01[i] = cp0.count;
                5'd12:  payloadRAM.cp01[i] = cp0.status;
                5'd13:  payloadRAM.cp01[i] = cp0.cause;
                5'd14:  payloadRAM.cp01[i] = cp0.epc;
                5'd16:  payloadRAM.cp01[i] = cp0.config_;
                default:payloadRAM.cp01[i] = '0;
            endcase    
        end
        
    end

    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            case (payloadRAM.creg2[i][4:0])
                5'd8:   payloadRAM.cp02[i] = cp0.badvaddr;
                5'd9:   payloadRAM.cp02[i] = cp0.count;
                5'd12:  payloadRAM.cp02[i] = cp0.status;
                5'd13:  payloadRAM.cp02[i] = cp0.cause;
                5'd14:  payloadRAM.cp02[i] = cp0.epc;
                5'd16:  payloadRAM.cp02[i] = cp0.config_;
                default:payloadRAM.cp02[i] = '0;
            endcase
        end
        
    end
    
    // update cp0 registers
    always_comb begin
        cp0_new = cp0;
        
        cp0_new.count = cp0_new.count + count_switch;

        // write
        for (int i=0; i<ISSUE_WIDTH; i++) begin
            if (retire.retire[i].ctl.cp0write) begin
                case (retire.retire[i].dst[4:0])
                    5'd9:   cp0_new.count   = retire.retire[i].data[31:0];
                    5'd11:  cp0_new.compare = retire.retire[i].data[31:0];
                    5'd12:  
                    begin
                            cp0_new.status.IM = retire.retire[i].data[15:8];
                            cp0_new.status.EXL = retire.retire[i].data[1];
                            cp0_new.status.IE = retire.retire[i].data[0];
                    end
                    5'd13:  cp0_new.cause.IP[1:0] = retire.retire[i].data[9:8];
                    5'd14:  cp0_new.epc = retire.retire[i].data[31:0];
                    default: ;
                endcase
            end
        end
        

        // exception
        if (exception.valid) begin
            if (~cp0.status.EXL) begin
                if (exception.in_delay_slot) begin
                    cp0_new.cause.BD = 1'b1;
                    cp0_new.epc = exception.pcplus8 - 32'd12;
                end else begin
                    cp0_new.cause.BD = 1'b0;
                    cp0_new.epc = exception.pcplus8 - 32'd8;
                end
            end

            cp0_new.cause.exccode = exception.code;

            cp0_new.status.EXL = 1'b1;
            if (exception.code == CODE_ADEL || exception.code == CODE_ADES) begin
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
    assign is_eret = excep.is_eret;
    assign exception = excep.exception;
    assign excep.cp0_status = cp0.status;
    assign excep.cp0_cause = cp0.cause;
    // assign excep.cp0_data = cp0;
    assign pcselect.is_eret = is_eret;
    assign pcselect.epc = cp0.epc;
endmodule
