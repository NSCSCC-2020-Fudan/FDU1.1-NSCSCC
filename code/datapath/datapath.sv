`include "../interface.svh"
module datapath 
    import common::*;(
    input logic clk, resetn
);
    dreg_intf dreg_intf();
    rreg_intf rreg_intf();
    ireg_intf ireg_intf();
    ereg_intf ereg_intf();
    creg_intf creg_intf();

    forward_intf forward_intf();


    decode decode();
    renaming renaming();
    issue issue();
    execute execute();
    commit commit();

    rat rat(.clk, .resetn);
    rob rob(.clk, .resetn);

    dreg dreg(.clk, .resetn, .ports(dreg_intf.dreg));
    rreg rreg(.clk, .resetn, .ports(rreg_intf.rreg));
    ireg ireg(.clk, .resetn, .ports(ireg_intf.ireg));
    ereg ereg(.clk, .resetn, .ports(ereg_intf.ereg));
    creg creg(.clk, .resetn, .ports(creg_intf.creg));
endmodule