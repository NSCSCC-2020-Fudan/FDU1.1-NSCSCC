`include "mips.svh"

module decode(
        input fetch_data_t [1: 0] in,
        input logic [1: 0] hitF,
        output decode_data_t [1: 0] out,
        output logic [1: 0] hitD
        //input cp0_status_t cp0_status,
        //input cp0_status_t cp0_cause
    );
    signaldecode signaldecode1 (in[1], out[1]);
    signaldecode signaldecode0 (in[0], out[0]);
    
    (*mark_debug = "true"*) logic debug1, debug0;
    assign debug1 = out[1].pred.taken & (
                    (out[1].pred.destpc != out[1].instr.pcbranch & out[1].instr.ctl.branch) |
                    (out[1].pred.destpc != out[1].instr.pcjump & out[1].instr.ctl.jump)     |
                    (~out[1].instr.ctl.branch & ~out[1].instr.ctl.jump)                      );
    assign debug0 = out[0].pred.taken & (
                    (out[0].pred.destpc != out[0].instr.pcbranch & out[0].instr.ctl.branch) |
                    (out[0].pred.destpc != out[0].instr.pcjump & out[0].instr.ctl.jump)     |
                    (~out[0].instr.ctl.branch & ~out[0].instr.ctl.jump)                      );                   
     
    assign hitD = hitF;
endmodule
