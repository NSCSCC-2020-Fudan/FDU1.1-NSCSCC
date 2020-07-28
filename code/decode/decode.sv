`include "interface.svh"
module decode 
    import common::*;
    import decode_pkg::*;(
    dreg_intf.decode dreg,
    rreg_intf.decode rreg
);
    fetch_pkg::fetch_data_t [MACHINE_WIDTH-1:0] dataF;
    decode_data_t [MACHINE_WIDTH-1:0] dataD;
    logic [MACHINE_WIDTH-1:0] exception_ri;
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        decoder decoder(.instr_(dataF[i].instr_), .instr(dataD[i].instr), .exception_ri(exception_ri[i]));
    end

    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            dataD[i].pcplus8 = dataF[i].pcplus8;
            dataD[i].exception = dataF[i].exception;
            dataD[i].exception.ri = exception_ri[i];
        end
    end

    assign dataF = dreg_intf.dataF;
    assign rreg.dataD_new = dataD;
endmodule