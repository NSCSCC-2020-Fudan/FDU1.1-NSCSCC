module decode 
    import common::*;
    import decode_pkg::*;(
    
);
    fetch_data_t [MACHINE_WIDTH-1:0] dataF;
    decode_data_t [MACHINE_WIDTH-1:0] dataD;
    logic [MACHINE_WIDTH-1:0] exception_ri;
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        decoder decoder(.instr(dataF[i].instr_), .instr(dataD[i].instr), .exception_ri[i]);
    end

    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            dataD[i].pcplus4 = dataF[i].pcplus4;
            dataD[i].exception = dataF[i].exception;
            dataD[i].exception.ri = exception_ri[i];
        end
    end
endmodule