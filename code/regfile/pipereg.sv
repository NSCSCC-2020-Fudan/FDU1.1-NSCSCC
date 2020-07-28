`include "../interface.svh"
module freg 
    import common::*;(
    input logic clk, resetn,
    freg_intf.freg self
);
    logic stall;
    word_t pc, pc_new;
    always_ff @(posedge clk) begin
        if (~resetn) begin
            pc <= '0;
        end else if (~stall) begin
            pc <= pc_new;
        end
    end

    assign pc_new = self.pc_new;
    assign self.pc = pc;
endmodule

module dreg 
    import common::*;
    import fetch_pkg::*;(
    input logic clk, resetn,
    dreg_intf.dreg self
);
    logic stall, flush;
    fetch_data_t [MACHINE_WIDTH-1:0]dataF, dataF_new;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            dataF <= '0;
        end else if (~stall) begin
            dataF <= dataF_new;
        end
    end

    assign dataF_new = self.dataF_new;
    assign self.dataF = dataF;
endmodule

module rreg 
    import common::*;
    import decode_pkg::*;(
    input logic clk, resetn,
    rreg_intf.rreg self
);
    logic stall, flush;    
    decode_data_t [MACHINE_WIDTH-1:0]dataD, dataD_new;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            dataD <= '0;
        end else if (~stall) begin
            dataD <= dataD_new;
        end
    end

    assign dataD_new = self.dataD_new;
    assign self.dataD = dataD;
endmodule

module ireg 
    import common::*;
    import renaming_pkg::*;(
    input logic clk, resetn,
    ireg_intf.ireg self
);
    logic stall, flush;    
    renaming_data_t [MACHINE_WIDTH-1:0]dataR, dataR_new;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            dataR <= '0;
        end else if (~stall) begin
            dataR <= dataR_new;
        end
    end

    assign dataR_new = self.dataR_new;
    assign self.dataR = dataR;
endmodule

module ereg 
    import common::*;
    import issue_pkg::*;(
    input logic clk, resetn,
    ereg_intf.ereg self
);
    logic stall, flush;    
    issue_data_t dataI, dataI_new;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            dataI <= '0;
        end else if (~stall) begin
            dataI <= dataI_new;
        end
    end

    assign dataI_new = self.dataI_new;
    assign self.dataI = dataI;
endmodule

module creg 
    import common::*;
    import execute_pkg::*;(
    input logic clk, resetn,
    creg_intf.creg self
);
    logic stall, flush;    
    execute_data_t dataE, dataE_new;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            dataE <= '0;
        end else if (~stall) begin
            dataE <= dataE_new;
        end
    end

    assign dataE_new = self.dataE_new;
    assign self.dataE = dataE;
endmodule