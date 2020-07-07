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
    input logic clk, reset, en, clear
    input word_t instrF, pcplus4F,
    output word_t instrD, pcplus4D
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            {instrD, pcplus4D} <= '0;
        end
        else if(en & clear) begin
            {instrD, pcplus4D} <= '0;
        end else if(en) begin
            {instrD, pcplus4D} <= {instrF, pcplus4F};
        end
    end
endmodule

module Ereg (
    input logic clk, reset, clear,
    input decoded_instr_t decoded_instrD,
    output decoded_instr_t decoded_instrE
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            decoded_instrE <= '0;
        end
        else if(clear) begin
            decoded_instrE <= '0;
        end else begin
            decoded_instrE <= decoded_instrD;
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