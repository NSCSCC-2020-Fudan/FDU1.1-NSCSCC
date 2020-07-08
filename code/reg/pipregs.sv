`include "mips.svh"

module Freg (
    input logic clk, reset,
    pcselect_freg_fetch.freg ports,
    hazard_intf hazard
);
    logic en;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ports.pc <= '0;
        end
        else if(en) begin
            ports.pc <= ports.pc_new;
        end
    end
    assign en = ~hazard.stallF;
    
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
        else if(en & clear) begin
            dataF <= '0;
        end else if(en) begin
            dataF <= dataF_new;
        end
    end

    assign en = ~hazard.stallD;
    assign clear = hazard.flushD;
    assign dataF_new = ports.dataF_new;
    assign ports.dataF = dataF;
endmodule

module Ereg (
    input logic clk, reset, 
    decode_ereg_exec.ereg ports,
    hazard_intf.ereg hazard
);
    decode_data_t dataD, dataD_new;
    logic en, clear;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataD <= '0;
        end
        else if(en & clear) begin
            dataD <= '0;
        end else if(en) begin
            dataD <= dataD_new;
        end
    end

    assign en = ~hazard.stallE;
    assign clear = hazard.flushE;
    assign dataD_new = ports.dataD_new;
    assign ports.dataD = dataD;
endmodule

module Mreg (
    input logic clk, reset,
    exec_mreg_memory.mreg ports,
    hazard_intf.mreg hazard
);
    exec_data_t dataE, dataE_new;
    logic en, clear;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataE <= '0;
        end
        else if(en & clear) begin
            dataE <= '0;
        end else if(en) begin
            dataE <= dataE_new;
        end
    end

    assign en = ~hazard.stallM;
    assign clear = hazard.flushM;
    assign dataE_new = ports.dataE_new;
    assign ports.dataE = dataE;
endmodule

module Wreg (
    input logic clk, reset,
    memory_wreg_writeback.wreg ports,
    hazard_intf.wreg hazard
);
    mem_data_t dataM, dataM_new;
    logic clear;
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dataM <= '0;
        end
        else if(clear) begin
            dataM <= '0;
        end else begin
            dataM <= dataM_new;
        end
    end

    assign clear = hazard.flushW;
    assign dataM_new = ports.dataM_new;
    assign ports.dataM = dataM;
endmodule