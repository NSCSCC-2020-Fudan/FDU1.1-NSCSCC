module hazard (
    hazard_intf.hazard_p port
);
    logic CP0E, HILOE, RegE;
    logic CP0M, HILOM, RegM;

    always_comb begin
        
    end

    // assign CP0E = port.instrE.op == MTC0 && (CP0RegWriteE == port.instrE.rd) & (CP0RegWriteM == CP0RegReadD);
    // assign CP0M = PrivilegeWriteM & (CP0RegWriteE == CP0SelReadD) & (CP0RegWriteM == CP0RegReadD);
    assign HILOE = (HIWriteEnE & HIReadEnD) | (LOWriteEnE & LOReadEnD);
    assign HILOE = (HIWriteEnM & HIReadEnD) | (LOWriteEnM & LOReadEnD);
    assign RegE = ((RsD == WriteRegE) & WriteRegEnE) | ((RtD == WriteRegE) & WriteRegEnE);
    assign RegM = ((RsD == WriteRegM) & WriteRegEnM) | ((RtD == WriteRegM) & WriteRegEnM);
endmodule