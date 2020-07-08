`include "mips.svh"

module hazard (
    hazard_intf.hazard ports
);
    // logic CP0E, HILOE, RegE;
    // logic CP0M, HILOM, RegM;
    logic lwstall, branchstall;
    logic rt1, rt2, rs1, rs2;
    decode_data_t dataD;
    exec_data_t dataE;
    mem_data_t dataM;
    wb_data_t dataW;
    logic         flushD, flushE, flushM, flushW;
    logic stallF, stallD, stallE, stallM;
    word_t aluoutM, resultW;
    forward_t forwardAE, forwardBE, forwardAD, forwardBD;
    always_comb begin
        if ((dataE.instr.rs != 0) && (dataE.instr.rs == dataM.writereg) && dataM.instr.ctl.regwrite) begin
            forwardAE = M;
        end else if ((dataE.instr.rs != 0) && (dataE.instr.rs == dataW.writereg) && dataW.instr.ctl.regwrite) begin
            forwardAE = W;
        end else begin
            forwardAE = ORI;
        end
        if ((dataE.instr.rt != 0) && (dataE.instr.rs == dataM.writereg) && dataM.instr.ctl.regwrite) begin
            forwardBE = M;
        end else if ((dataE.instr.rt != 0) && (dataE.instr.rs == dataW.writereg) && dataW.instr.ctl.regwrite) begin
            forwardBE = W;
        end else begin
            forwardBE = ORI;
        end
        if ((dataD.instr.rs != 0) && (dataD.instr.rs == dataM.writereg) && dataM.instr.ctl.regwrite) begin
            forwardAD = M;
        end else if ((dataD.instr.rs != 0) && (dataD.instr.rs == dataW.writereg) && dataW.instr.ctl.regwrite) begin
            forwardAD = W;
        end else begin
            forwardAD = ORI;
        end
        if ((dataD.instr.rt != 0) && (dataD.instr.rs == dataM.writereg) && dataM.instr.ctl.regwrite) begin
            forwardBD = M;
        end else if ((dataD.instr.rt != 0) && (dataD.instr.rs == dataW.writereg) && dataW.instr.ctl.regwrite) begin
            forwardBD = W;
        end else begin
            forwardBD = ORI;
        end
    end

    // assign CP0E = port.instrE.op == MTC0 && (CP0RegWriteE == port.instrE.rd) & (CP0RegWriteM == CP0RegReadD);
    // assign CP0M = PrivilegeWriteM & (CP0RegWriteE == CP0SelReadD) & (CP0RegWriteM == CP0RegReadD);
    // assign HILOE = (HIWriteEnE & HIReadEnD) | (LOWriteEnE & LOReadEnD);
    // assign HILOE = (HIWriteEnM & HIReadEnD) | (LOWriteEnM & LOReadEnD);
    // assign RegE = ((dataD.instr.rs == dataE.writereg) & dataE.instr.ctl.regwrite) |
    //               ((dataD.instr.rt == dataE.writereg) & dataE.instr.ctl.regwrite);
    // assign RegM = ((dataD.instr.rs == dataM.writereg) & dataM.instr.ctl.memread) |
    //               ((dataD.instr.rt == dataM.writereg) & dataM.instr.ctl.memread);
    assign rt1 = ((dataD.instr.rt == dataE.writereg) & dataE.instr.ctl.regwrite);
    assign rs1 = ((dataD.instr.rs == dataE.writereg) & dataE.instr.ctl.regwrite);
    assign rt2 = ((dataD.instr.rt == dataM.writereg) & dataM.instr.ctl.memread);
    assign rs2 = ((dataD.instr.rs == dataM.writereg) & dataM.instr.ctl.memread);
    assign lwstall = dataE.instr.ctl.memread &&
                    (dataD.instr.rs == dataE.instr.rt ||
                     dataD.instr.rt == dataE.instr.rt);
    assign branchstall = (dataD.instr.ctl.jr || dataD.instr.ctl.branch) &&
                         (rt1 || rs1 || rt2 || rs2);
    assign stallF = lwstall | branchstall;
    assign stallD = stallF;
    assign stallE = '0;
    assign stallM = '0;
    assign flushD = '0;
    assign flushE = stallF;
    assign flushM = '0;
    assign flushW = '0;
endmodule