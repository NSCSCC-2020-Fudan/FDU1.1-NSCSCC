`include "MIPS.svh"

module Hazard(
        input logic [4: 0] RsD, RtD
        input logic HIReadEnD, LOReadEnD,
        input logic PrivilegeReadD,
		input logic [4: 0] CP0RegReadD,
		input logic [2: 0] CP0SelReadD,

        input logic WriteRegEnE,
        input logic [4: 0] WriteRegE,
        input logic HIWriteEnE, LOWriteEnE,
        input logic PrivilegeWriteE,
        input logic [4: 0] CP0RegWriteE,
        input logic [4: 0] CP0SelWriteE,

        input logic WriteRegEnM,
        input logic [4: 0] WriteRegM,
        input logic HIWriteEnM, LOWriteEnM,
        input logic PrivilegeWriteM,
        input logic [4: 0] CP0RegWriteM,
        input logic [4: 0] CP0SelWriteM,

        output logic DataHarzard
    );

    logic CP0E, HILOE, RegE;
    logic CP0M, HILOM, RegM;
    assign CP0E = PrivilegeWriteE & (CP0RegWriteE == CP0SelReadD) & (CP0RegWriteM == CP0RegReadD);
    assign CP0M = PrivilegeWriteM & (CP0RegWriteE == CP0SelReadD) & (CP0RegWriteM == CP0RegReadD);
    assign HILOE = (HIWriteEnE & HIReadEnD) | (LOWriteEnE & LOReadEnD);
    assign HILOE = (HIWriteEnM & HIReadEnD) | (LOWriteEnM & LOReadEnD);
    assign RegE = ((RsD == WriteRegE) & WriteRegEnE) | ((RtD == WriteRegE) & WriteRegEnE);
    assign RegE = ((RsD == WriteRegM) & WriteRegEnM) | ((RtD == WriteRegM) & WriteRegEnM);

    assign DataHarzard = CP0E | CP0M | HILOE | HILOM | RegE | RegM;
endmodule