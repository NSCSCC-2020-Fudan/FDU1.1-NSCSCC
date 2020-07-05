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
    logic IP7, IP6, IP5, IP4, IP3, IP2; // [15:10]
    logic IP1, IP0; // [9:8]
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

module CP0 (
    input logic clk, reset,

    // read
    input logic [4:0]ra, 
    output logic [31:0]rd,

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
        endcase
    end

    // BadVAddr
    always_ff @(posedge clk, posedge reset) begin
        // TODO:
    end

    // Count
    logic count_sup;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.Count <= 32'b0;
            count_sup <= 1'b0;
        end else begin
            cp0.Count <= cp0.Count + count_sup;
            count_sup <= ~count_sup;
        end
    end

    // Status
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.Status <= 32'b00000000_01000000_00000000_00000000;
        end
        else begin
            
        end
    end

    // Cause
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.Cause <= '0;
        end
        else begin
            
        end
    end

    // EPC
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cp0.EPC <= '0;
        end
        else begin
            
        end
    end
endmodule