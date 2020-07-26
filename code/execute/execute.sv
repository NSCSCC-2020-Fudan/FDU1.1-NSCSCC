`include "../interface.svh"

module execute 
    import common::*;
    import execute_pkg::*;(
    input clk, resetn,
    ereg_intf.execute ereg,
    creg_intf.execute creg,
    forward_intf.execute forward
);
    issue_pkg::issue_data_t dataI;
    execute_data_t dataE;
    // forward
    
    
    // ALU
    for (genvar i=0; i<ALU_NUM; i++) begin
        alu alu(.a(), .b(),
                .alufunc(),
                .c(),
                .exception_of());
    end

    // AGU
    for (genvar i=0; i<AGU_NUM; i++) begin
        agu agu(.clk, .resetn,
                .src1, .src2,
                .rd_, .wd_,
                .rd, .wd);
    end

    // BRU
    for (genvar i=0; i<BRU_NUM; i++) begin
        bru bru();
    end

    // MULT
    for (genvar i=0; i<MULT_NUM; i++) begin
        mult mult();
    end

    // wake in execute
endmodule