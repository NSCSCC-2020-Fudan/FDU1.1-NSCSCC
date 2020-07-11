`include "mips.svh"

module hazard (
    hazard_intf.hazard ports
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
    logic i_data_ok;
    logic hiwriteM, lowriteM, cp0writeM, hiwriteW, lowriteW, cp0writeW;
    logic hitoregE, lotoregE, cp0toregE;
    alufunc_t alufuncE;
    logic is_multM, is_multW;
    logic is_eret;
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
        end else if ((hiwriteM && hitoregE) || (lowriteM && lotoregE) || (cp0writeM && cp0toregE)) begin
            forwardAE = ALUOUTM;
        end else if (rsE != 0 && rsE == writeregM && regwriteM) begin
            forwardAE = ALUOUTM;
        end else if (is_multW && hitoregE) begin
            forwardAE = HIW;
        end else if (is_multW && lotoregE) begin
            forwardAE = LOW;
        end else if ((hiwriteW && hitoregE) || (lowriteW && lotoregE) || (cp0writeW && cp0toregE)) begin
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


    assign stallF = lwstall | branchstall | ~i_data_ok;
    assign stallD = stallF;
    assign stallE = '0;
    assign stallM = '0;
    assign flushD = exception_validM | is_eret;
    assign flushE = stallF | exception_validM | is_eret;
    assign flushM = exception_validM | is_eret;
    assign flushW = exception_validM;

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
endmodule