`include "mips.svh"

module fetch (
    pcselect_freg_fetch.fetch in,
    fetch_dreg_decode.fetch out,
    pcselect_intf.fetch pcselect,
    hazard_intf.fetch hazard,
    input logic clk, resetn,
    input logic i_data_ok, d_data_ok, d_addr_ok, i_addr_ok,
    output word_t pc
);
    word_t pcplus4, pcplus4_2;
    // word_t pc;
    fetch_data_t dataF;
    logic exception_instr;
    assign pc = ((~hazard.stallD | hazard.flushD) & valid1) ? in.pc : pcplus4_2 - 4;
    adder#(32) pcadder(pc, 32'b100, pcplus4);
    assign exception_instr = (dataF.pcplus4[1:0] != '0);
    logic valid1, valid2, valid2_self;
    always_ff @(posedge clk) begin
        if (~resetn) begin
            pcplus4_2 <= 32'hbfc00004;
            valid2 <= 1'b1;
        end else if(~hazard.stallD)begin
            pcplus4_2 <= pcplus4;
            valid2 <= valid1;
        end
    end
    assign valid1 = (~hazard.dataD.branch_taken | hazard.branchstall) & ~hazard.flush_ex;
    // always_ff @(posedge clk) begin
    //     if ( ~resetn ) begin
    //         valid2_self <= 1'b1;
    //     end else begin
    //         valid2_self <= d_data_ok;
    //     end
    // end
    assign valid2_self = d_data_ok;
    assign dataF.instr_ = out.instr_ & {32{valid2 & valid2_self}};
    assign dataF.pcplus4 = pcplus4_2 & {32{valid2 & valid2_self}};
    assign dataF.exception_instr = exception_instr;
    assign out.dataF_new = dataF;
    assign pcselect.pcplus4F = pcplus4;
    assign dataF.in_delay_slot = out.in_delay_slot;
    assign hazard.valid1 = valid1;
endmodule
