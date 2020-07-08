`include "mips.svh"

module Freg (
    input logic clk, reset,
    input word_t pcnext,
    output word_t pc
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            pc <= '0;
        end
        else if(~stall) begin
            pc <= pcnext;
        end
    end
endmodule

module Dreg (
    input logic clk, reset, en, clear,
    input fetch_data_t dataF,
    output fetch_data_t dataD
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataD <= '0;
        end
        else if(en & clear) begin
            dataD <= '0;
        end else if(en) begin
            dataD <= dataF;
        end
    end
endmodule

module Ereg (
    input logic clk, reset, clear,
    input decode_data_t dataD,
    output decode_data_t data_E
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataE <= '0;
        end
        else if(clear) begin
            dataE <= '0;
        end else begin
            dataE <= dataD;
        end
    end
endmodule

module Mreg (
    input logic clk, reset,
    input exec_data_t dataE,
    output exec_data_t dataM
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataM <= '0;
        end
        else begin
            dataM <= dataE;
        end
    end
endmodule

module Wreg (
    input logic clk, reset,
    input mem_data_t dataM,
    output mem_data_t dataW
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataW <= '0;
        end
        else begin
            dataW <= dataM;
        end
    end
endmodule