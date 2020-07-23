`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

interface forward_intf;
    import common::*;
    import forward_pkg::*;
    import execute_pkg::*;

    forward_t [FU_NUM-1:0] forwards; // to execute
    preg_addr_t [ALU_NUM-1:0] src1, src2; // from execute
    preg_addr_t [ALU_NUM-1:0] dst; // from commit
    word_t [ALU_NUM-1:0] data;
    modport forward(input src1, src2, dst, output forwards);
    modport execute(input forwards, output src1, src2);
    modport commit(output dst, data);
endinterface //forward_intf

`endif
