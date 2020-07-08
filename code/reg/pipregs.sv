`include "mips.svh"

module Freg_ (
    input logic clk, reset,
    pcselect_freg_fetch.freg ports,
    hazard_intf hazard
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.pc <= '0;
        end
        else if(~hazard.stallF) begin
            ports.pc <= ports.pc_new;
        end
    end
    
endmodule

module Dreg_ (
    input logic clk, reset,
    fetch_dreg_decode.dreg ports,
    hazard_intf.dreg hazard
);
    fetch_data_t dataF_new, dataF;
    logic en, clear;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.dataF <= '0;
        end
        else if(~hazard.stallD & hazard.flushD) begin
            ports.dataF <= '0;
        end else if(~hazard.stallD) begin
            ports.dataF <= ports.dataF_new;
        end
    end
endmodule

module Ereg_ (
    input logic clk, reset, 
    decode_ereg_exec.ereg ports,
    hazard_intf.ereg hazard
);
    decode_data_t dataD, dataD_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.dataD <= 0;
        end
        else if(~hazard.stallE & hazard.flushE) begin
            ports.dataD <= '0;
        end else if(~hazard.stallE) begin
            ports.dataD <= ports.dataD_new;
        end
    end
endmodule

module Mreg_ (
    input logic clk, reset,
    exec_mreg_memory.mreg ports,
    hazard_intf.mreg hazard
);
    exec_data_t dataE, dataE_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.dataE <= '0;
        end
        else if(~hazard.stallM & hazard.flushM) begin
            ports.dataE <= '0;
        end else if(~hazard.stallM) begin
            ports.dataE <= ports.dataE_new;
        end
    end
endmodule

module Wreg_ (
    input logic clk, reset,
    memory_wreg_writeback.wreg ports,
    hazard_intf.wreg hazard
);
    mem_data_t dataM, dataM_new;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.dataM <= '0;
        end
        else if(hazard.flushW)begin
            ports.dataM <= '0;
        end else begin
            ports.dataM <= ports.dataM_new;
        end
    end
endmodule