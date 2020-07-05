`include "MIPS.svh"

module CP0 (
    input logic clk, reset,

    // read
    input logic [4:0]ra, 
    output logic [31:0]rd,

    // write
    input logic w_en,
    input logic [4:0]wa,
    input logic [31:0]wd,

    // exception
    input Exception exception,

    // interrupt
    input logic [7:0] interrupt,

    output CP0_REG cp0
);

    // read
    always_comb begin
        case (ra)
            5'd8: rd <= cp0.BadVAddr;
            5'd9: rd <= cp0.Count;
            5'd12: rd <= cp0.Status;
            5'd13: rd <= cp0.Cause;
            5'd14: rd <= cp0.EPC;
            default: rd <= '0;
        endcase
    end

    // BadVAddr
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.BadVAddr <= '0;
        end
        else if(exception.valid & (exception.mode == /*TODO*/)) begin
            cp0.BadVAddr <= exception.va;
        end
    end

    // Count
    logic count_sup;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.Count <= 32'b0;
            count_sup <= 1'b0;
        end else if (w_en & (wa == 5'd9)) begin
            cp0.Count <= wd;
            count_sup <= 1'b0;
        end 
        else begin
            cp0.Count <= cp0.Count + count_sup;
            count_sup <= ~count_sup;
        end
    end

    // Status
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.Status <= 32'b00000000_01000000_00000000_00000000;
        end else begin 
            if (we & (wa == 5'd12)) begin
                {cp0.Status[15:8], cp0.Status[1:0]} <= {wd[15:8], wd[1:0]};
            end
            if (exception.valid) begin
                cp0.Status.EXL <= 1'b1;
            end
        end
    end

    // Cause
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.Cause <= '0;
        end
        else begin
            cp0.Cause.IP[7:2] <= interrupt[7:2];
            if(w_en & (wa == 5'd13)) begin
                cp0.Cause.IP[1:0] <= wd[1:0];
            end
            if(exception.valid) begin
                cp0.Cause.ExcCode <= exception.mode;
                cp0.Cause.BD <= exception.isbranch;
            end
        end
    end

    // EPC
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.EPC <= '0;
        end
        else if(exception.valid & cp0.Status.EXL) begin // note: different from ntm
            if (exception.isbranch) begin
                cp0.EPC <= exception.pc - 32'd4;
            end
            else begin
                cp0.EPC <= exception.pc;
            end
        end else if (w_en & (wa == 5'd14)) begin
            cp0.EPC <= wd;
        end
    end

endmodule