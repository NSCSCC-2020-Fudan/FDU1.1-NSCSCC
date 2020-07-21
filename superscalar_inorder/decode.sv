`include "mips.svh"

module decode(
        input fetch_data_t [1: 0] in,
        input logic [1: 0] hitF,
        output decode_data_t [1: 0] out,
        output logic [1: 0] hitD
        //input cp0_status_t cp0_status,
        //input cp0_status_t cp0_cause
    );
    signaldecode signaldecode [1: 0] (in, out); 
    assign hitD = hitF;
endmodule
