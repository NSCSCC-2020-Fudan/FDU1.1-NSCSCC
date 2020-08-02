`include "mips.svh"

module hazard (
    hazard_intf.hazard ports,
    pcselect_intf.hazard pcselect,
    input logic clk, resetn
);
    // logic CP0E, HILOE, RegE;
    // logic CP0M, HILOM, RegM;
    logic lwstall, branchstall;
    logic         flushD, flushE, flushM, flushW;
    logic stallF, stallD, stallE, stallM;
    // word_t aluoutM, resultW;
    forward_t forwardAE, forwardBE, forwardAD, forwardBD;
    creg_addr_t rtD, rsD, rtE, rsE, writeregE, writeregM, writeregW;  
    logic regwriteE, regwriteM, regwriteW, memtoregE, memtoregM;
    decoded_op_t opD, opE, opM, opW;
    logic branchD, jrD;
    logic exception_validM;
    logic i_data_ok, d_data_ok;
    logic hiwriteM, lowriteM, cp0writeM, hiwriteW, lowriteW, cp0writeW;
    logic hitoregE, lotoregE, cp0toregE;
    alufunc_t alufuncE;
    logic is_multM, is_multW;
    logic is_eret;
    creg_addr_t cp0_addrE, cp0_addrM, cp0_addrW;
    logic mult_ok;
    always_comb begin
        if (rsD != 0) begin
            if (rsD == writeregE && regwriteE && (alufuncE == ALU_PASSA)) begin
                forwardAD = ALUSRCAE;
            end else if(rsD == writeregM && regwriteM) begin
                forwardAD = ALUOUTM;
            end else if (rsD == writeregW && regwriteW) begin
                forwardAD = RESULTW;
            end else begin
                forwardAD = NOFORWARD;
            end
        end
        else begin
            forwardAD = NOFORWARD;
        end
        if (rtD != 0) begin
            if (rtD == writeregE && regwriteE && (alufuncE == ALU_PASSA)) begin
                forwardBD = ALUSRCAE;
            end else if (rtD == writeregM && regwriteM) begin
                forwardBD = ALUOUTM;
            end else if (rtD == writeregW && regwriteW) begin
                forwardBD = RESULTW;
            end else begin
                forwardBD = NOFORWARD;
            end
        end
        else begin
            forwardBD = NOFORWARD;
        end
        if (is_multM && hitoregE) begin
            forwardAE = HIM;
        end else if (is_multM && lotoregE) begin
            forwardAE = LOM;
        end else if ((hiwriteM && hitoregE) || (lowriteM && lotoregE) || (cp0writeM && cp0toregE && cp0_addrM == cp0_addrE)) begin
            forwardAE = ALUOUTM;
        end else if (rsE != 0 && rsE == writeregM && regwriteM) begin
            forwardAE = ALUOUTM;
        end else if (is_multW && hitoregE) begin
            forwardAE = HIW;
        end else if (is_multW && lotoregE) begin
            forwardAE = LOW;
        end else if ((hiwriteW && hitoregE) || (lowriteW && lotoregE) || (cp0writeW && cp0toregE && cp0_addrW == cp0_addrE)) begin
            forwardAE = RESULTW;
        end else if (rsE != 0 && rsE == writeregW && regwriteW) begin
            forwardAE = RESULTW;
        end else begin
            forwardAE = NOFORWARD;
        end
        if (rtE != 0) begin
            if (rtE == writeregM && regwriteM) begin
                forwardBE = ALUOUTM;
            end else if (rtE == writeregW && regwriteW) begin
                forwardBE = RESULTW;
            end else begin
                forwardBE = NOFORWARD;
            end
        end
        else begin
            forwardBE = NOFORWARD;
        end
    end
    assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
    assign branchstall = (branchD || jrD) && (alufuncE != ALU_PASSA) && 
                         (((regwriteE && (writeregE == rsD))||(memtoregM && (writeregM == rsD)))||
                         ((opD == BEQ || opD == BNE) && (regwriteE && (writeregE == rtD))||(memtoregM && (writeregM == rtD))));

    logic flush_ex;
    assign flush_ex = exception_validM | is_eret;
    // logic flush_ex1;
    // always_ff @(posedge clk) begin
    //     if (~resetn) begin
    //         flush_ex1 <= 1'b0;
    //     end else if (~flush_ex) begin
    //         flush_ex1 <= flush_ex;
    //     end else if(~stallF)begin
    //         flush_ex1 <= flush_ex1;
    //     end
    // end
    

    assign stallF = ~i_data_ok | ~d_data_ok | ((lwstall | branchstall) & ~flush_ex)|~mult_ok; // meet eret?
    assign stallD = ~d_data_ok | ~i_data_ok | ((lwstall | branchstall) & ~flush_ex)|~mult_ok;
    assign stallE = ~d_data_ok | (~i_data_ok & flush_ex) | ~mult_ok;
    assign stallM = ~d_data_ok | (~i_data_ok & flush_ex);
    assign flushD = flush_ex;
    assign flushE = lwstall | branchstall | flush_ex | ~i_data_ok;
    assign flushM = flush_ex | ~mult_ok;
    assign flushW = flush_ex | ~d_data_ok;

    assign rtD = ports.dataD.instr.rt;
    assign rsD = ports.dataD.instr.rs;
    assign rtE = ports.dataE.instr.rt;
    assign rsE = ports.dataE.instr.rs;
    assign writeregE = ports.dataE.writereg;
    assign writeregM = ports.dataM.writereg;
    assign writeregW = ports.dataW.writereg;
    assign regwriteE = ports.dataE.instr.ctl.regwrite;
    assign regwriteM = ports.dataM.instr.ctl.regwrite;
    assign regwriteW = ports.dataW.instr.ctl.regwrite;
    assign memtoregE = ports.dataE.instr.ctl.memtoreg;
    assign memtoregM = ports.dataM.instr.ctl.memtoreg;
    assign opD = ports.dataD.instr.op;
    assign opE = ports.dataE.instr.op;
    assign opM = ports.dataM.instr.op;
    assign opW = ports.dataW.instr.op;
    assign branchD = ports.dataD.instr.ctl.branch;
    assign jrD = ports.dataD.instr.ctl.jr;
    assign exception_validM = ports.exception_valid;
    assign i_data_ok = ports.i_data_ok;
    assign d_data_ok = ports.d_data_ok;
    assign hiwriteM = ports.dataM.instr.ctl.hiwrite;
    assign lowriteM = ports.dataM.instr.ctl.lowrite;
    assign cp0writeM = ports.dataM.instr.ctl.cp0write;
    assign hiwriteW = ports.dataW.instr.ctl.hiwrite;
    assign lowriteW = ports.dataW.instr.ctl.lowrite;
    assign cp0writeW = ports.dataW.instr.ctl.cp0write;
    assign hitoregE = ports.dataE.instr.ctl.hitoreg;
    assign lotoregE = ports.dataE.instr.ctl.lotoreg;
    assign cp0toregE = ports.dataE.instr.ctl.cp0toreg;
    assign alufuncE = ports.dataE.instr.ctl.alufunc;
    assign is_multM = hiwriteM & lowriteM;
    assign is_multW = hiwriteW & lowriteW;
    assign is_eret = ports.is_eret;
    assign mult_ok = ports.mult_ok;
    assign cp0_addrE = ports.dataE.instr.rd;
    assign cp0_addrM = ports.dataM.instr.rd;
    assign cp0_addrW = ports.dataW.instr.rd;
    assign ports.stallF = stallF;
    assign ports.stallD = stallD;
    assign ports.stallE = stallE;
    assign ports.stallM = stallM;
    assign ports.flushD = flushD;
    assign ports.flushE = flushE;
    assign ports.flushM = flushM;
    assign ports.flushW = flushW;
    assign ports.resultW = ports.dataW.result;
    assign ports.aluoutM = ports.dataM.aluout;
    assign ports.forwardAD = forwardAD;
    assign ports.forwardAE = forwardAE;
    assign ports.forwardBD = forwardBD;
    assign ports.forwardBE = forwardBE;
    assign ports.hiM = ports.dataM.hi;
    assign ports.loM = ports.dataM.lo;
    assign ports.hiW = ports.dataW.hi;
    assign ports.loW = ports.dataW.lo;
    assign pcselect.stallF = stallF;
    assign ports.flush_ex = flush_ex;
endmodule