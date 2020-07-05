typedef struct packed {
    logic [8:0] zero_0; // [31:23], always 0
    logic Bev; // [22], always 1
    logic [5:0] zero_1; // [21:16], always 0
    logic IM7, IM6, IM5, IM4, IM3, IM2, IM1, IM0; // [15:8]
    logic [5:0] zero_2; // [7:2]
    logic EXL; // [1]
    logic IE; // [0]
} CP0_STATUS; // CP0 register 12, select 0

typedef struct packed {
    logic BD; // [31]
    logic TI; // [30]
    logic [14:0]zero_0; // [29:16], always 0
    logic [7:0]IP; // [15:8]
    logic zero_1; // [7]
    logic [4:0]ExcCode; // [6:2]
    logic zero_2; // [1:0]
} CP0_CAUSE;

typedef struct packed {
    logic [31:0] EPC; // 14
    CP0_CAUSE Cause; // 13
    CP0_STATUS Status; // 12
    logic [31:0] Count, BadVAddr; // 9, 8
} CP0_REG;


typedef struct packed {
    logic valid;
    logic [31:0]pc;
    logic [3:0]mode;
    logic [31:0]va;
    logic isbranch;
} Except;

module CP0 (
    input logic clk, reset,

    // read
    input logic [4:0]ra, 
    output logic [31:0]rd,

    // write
    input logic w_en,
    input logic [4:0]wa,
    input logic [31:0]wd,

    // except
    input Except except,

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
        else if(except.valid & (except.mode == /*TODO*/)) begin
            cp0.BadVAddr <= except.va;
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
            if (except.valid) begin
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
            if(except.valid) begin
                cp0.Cause.ExcCode <= except.mode;
                cp0.Cause.BD <= except.isbranch;
            end
        end
    end

    // EPC
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.EPC <= '0;
        end
        else if(except.valid & cp0.Status.EXL) begin // note: different from ntm
            if (except.isbranch) begin
                cp0.EPC <= except.pc - 32'd4;
            end
            else begin
                cp0.EPC <= except.pc;
            end
        end else if (w_en & (wa == 5'd14)) begin
            cp0.EPC <= wd;
        end
    end

endmodule