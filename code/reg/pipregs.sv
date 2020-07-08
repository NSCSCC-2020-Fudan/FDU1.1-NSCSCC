`include "mips.svh"

module Freg (
    input logic clk, reset,
    pcselect_freg_fetch.freg ports,
    hazard_intf hazard
);
    word_t pc, pc_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            pc <= '0;
        end
        else if(~hazard.stallF) begin
            pc <= pc_new;
        end
    end
endmodule

module Dreg (
    input logic clk, reset,
    fetch_dreg_decode.dreg ports,
    hazard_intf.dreg hazard
);
    fetch_data_t dataF_new, dataF;
    logic en, clear;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataF <= '0;
        end
        else if(~hazard.stallD & hazard.flushD) begin
            dataF <= '0;
        end else if(~hazard.stallD) begin
            dataF <= dataF_new;
        end
    end
endmodule

module Ereg (
    input logic clk, reset, 
    decode_ereg_exec.ereg ports,
    hazard_intf.ereg hazard
);
    decode_data_t dataD, dataD_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataD <= '0;
        end
        else if(~hazard.stallE & hazard.flushE) begin
            dataD <= '0;
        end else if(~hazard.stallE) begin
            dataD <= dataD_new;
        end
    end
endmodule

module Mreg (
    input logic clk, reset,
    exec_mreg_memory.mreg ports,
    hazard_intf.mreg hazard
);
    exec_data_t dataE, dataE_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataE <= '0;
        end
        else if(~hazard.stallM & hazard.flushM) begin
            dataE <= '0;
        end else if(~hazard.stallM) begin
            dataE <= dataE_new;
        end
    end
endmodule

module Wreg (
    input logic clk, reset,
    memory_wreg_writeback.ereg ports,
    hazard_intf.wreg hazard
);
    mem_data_t dataM, dataM_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataM <= '0;
        end
        else if(hazard.flushW)begin
            dataM <= '0;
        end else begin
            dataM <= dataM_new;
        end
    end
endmodule