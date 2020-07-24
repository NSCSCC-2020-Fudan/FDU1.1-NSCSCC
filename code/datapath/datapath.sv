`include "../interface.svh"
module datapath 
    import common::*;(
    input logic clk, resetn
);
    dreg_intf dreg_intf();
    rreg_intf rreg_intf();
    forward_intf forward_intf();
    rob_intf rob_intf();
endmodule