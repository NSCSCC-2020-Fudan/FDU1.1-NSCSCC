`include "mips.svh"

module hazard (
    hazard_intf.hazard ports
);
    // logic CP0E, HILOE, RegE;
    // logic CP0M, HILOM, RegM;
    logic lwstall, branchstall;
    logic rt1, rt2, rs1, rs2;
    always_comb begin
        if ((ports.dataE.decoded_instr.rs != 0) && (ports.dataE.decoded_instr.rs == ports.dataM.writereg) && ports.dataM.decoded_instr.ctl.regwrite) begin
            forwardAE = M;
        end else if ((ports.dataE.decoded_instr.rs != 0) && (ports.dataE.decoded_instr.rs == ports.dataW.writereg) && ports.dataW.decoded_instr.ctl.regwrite) begin
            forwardAE = W;
        end else begin
            forwardAE = E;
        end
        if ((ports.dataE.decoded_instr.rt != 0) && (ports.dataE.decoded_instr.rs == ports.dataM.writereg) && ports.dataM.decoded_instr.ctl.regwrite) begin
            forwardBE = M;
        end else if ((ports.dataE.decoded_instr.rt != 0) && (ports.dataE.decoded_instr.rs == ports.dataW.writereg) && ports.dataW.decoded_instr.ctl.regwrite) begin
            forwardBE = W;
        end else begin
            forwardBE = E;
        end
        if ((ports.dataD.decoded_instr.rs != 0) && (ports.dataD.decoded_instr.rs == ports.dataM.writereg) && ports.dataM.decoded_instr.ctl.regwrite) begin
            forwardAD = M;
        end else if ((ports.dataD.decoded_instr.rs != 0) && (ports.dataD.decoded_instr.rs == ports.dataW.writereg) && ports.dataW.decoded_instr.ctl.regwrite) begin
            forwardAD = W;
        end else begin
            forwardAD = D;
        end
        if ((ports.dataD.decoded_instr.rt != 0) && (ports.dataD.decoded_instr.rs == ports.dataM.writereg) && ports.dataM.decoded_instr.ctl.regwrite) begin
            forwardBD = M;
        end else if ((ports.dataD.decoded_instr.rt != 0) && (ports.dataD.decoded_instr.rs == ports.dataW.writereg) && ports.dataW.decoded_instr.ctl.regwrite) begin
            forwardBD = W;
        end else begin
            forwardBD = D;
        end
    end

    // assign CP0E = port.instrE.op == MTC0 && (CP0RegWriteE == port.instrE.rd) & (CP0RegWriteM == CP0RegReadD);
    // assign CP0M = PrivilegeWriteM & (CP0RegWriteE == CP0SelReadD) & (CP0RegWriteM == CP0RegReadD);
    // assign HILOE = (HIWriteEnE & HIReadEnD) | (LOWriteEnE & LOReadEnD);
    // assign HILOE = (HIWriteEnM & HIReadEnD) | (LOWriteEnM & LOReadEnD);
    // assign RegE = ((ports.dataD.decoded_instr.rs == ports.dataE.writereg) & ports.dataE.decoded_instr.ctl.regwrite) |
    //               ((ports.dataD.decoded_instr.rt == ports.dataE.writereg) & ports.dataE.decoded_instr.ctl.regwrite);
    // assign RegM = ((ports.dataD.decoded_instr.rs == ports.dataM.writereg) & ports.dataM.decoded_instr.ctl.memread) |
    //               ((ports.dataD.decoded_instr.rt == ports.dataM.writereg) & ports.dataM.decoded_instr.ctl.memread);
    assign rt1 = ((ports.dataD.decoded_instr.rt == ports.dataE.writereg) & ports.dataE.decoded_instr.ctl.regwrite);
    assign rs1 = ((ports.dataD.decoded_instr.rs == ports.dataE.writereg) & ports.dataE.decoded_instr.ctl.regwrite);
    assign rt2 = ((ports.dataD.decoded_instr.rt == ports.dataM.writereg) & ports.dataM.decoded_instr.ctl.memread);
    assign rs2 = ((ports.dataD.decoded_instr.rs == ports.dataM.writereg) & ports.dataM.decoded_instr.ctl.memread);
    assign lwstall = ports.dataE.decoded_instr.ctl.memread &&
                    (ports.dataD.decoded_instr.rs == ports.dataE.decoded_instr.rt ||
                     ports.dataD.decoded_instr.rt == ports.dataE.decoded_instr.rt);
    assign branchstall = (ports.dataD.decoded_instr.ctl.jr || ports.dataD.decoded_instr.ctl.branch) &&
                         (rt1 || rs1 || rt2 || rs2);
    assign ports.stallF = lwstall | branchstall;
    assign ports.stallD = ports.stallF;
    assign ports.stallE = '0;
    assign ports.stallM = '0;
    assign ports.flushD = '0;
    assign ports.flushE = ports.stallF;
    assign ports.flushM = '0;
    assign ports.flushW = '0;
endmodule