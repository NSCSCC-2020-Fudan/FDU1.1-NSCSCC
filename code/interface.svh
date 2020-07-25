`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

interface dreg_intf();
    import common::*;
    import fetch_pkg::*;
    fetch_data_t [MACHINE_WIDTH-1:0]dataF, dataF_new;
    modport fetch(output dataF_new);
    modport dreg(input dataF_new, output dataF);
    modport decode(input dataF);
endinterface // dreg_intf

interface rreg_intf();
    import decode_pkg::*;

    decode_data_t [MACHINE_WIDTH-1:0]dataD, dataD_new;
    modport decode(output dataD_new);
    modport rreg(input dataD_new, output dataD);
    modport renaming(input dataD);
endinterface

interface forward_intf();
    import common::*;
    import forward_pkg::*;
    import execute_pkg::*;

    forward_t [FU_NUM-1:0] forwards; // to execute
    preg_addr_t [FU_NUM-1:0] src1, src2; // from execute
    preg_addr_t [ALU_NUM-1:0] dst; // from commit
    word_t [ALU_NUM-1:0] data;
    modport forward(input src1, src2, dst, output forwards);
    modport execute(input forwards, data, output src1, src2);
    modport commit(output dst, data);
endinterface

interface rob_intf();
    import common::*;
    import rob_pkg::*;

    w_resp_t [MACHINE_WIDTH-1:0] w_resp; // rob -> renaming
    w_req_t [MACHINE_WIDTH-1:0] w_req;
    modport rob(
        input w_req,
        output rob_addr,
    );
    modport renaming(
        input rob_addr,
        output w_req
    );
    modport commit(
        input
        output
    );
endinterface // rob_intf

interface payloadRAM_intf();
    word_t []
endinterface

interface arf_intf();
    import common::*;
    import regfile_pkg::*;

    r_req_t [AREG_READ_PORTS-1:0] r_req;
    r_resp_t [AREG_READ_PORTS-1:0] r_resp;
    w_req_t [AREG_WRITE_PORTS-1:0] w_req;
endinterface

`endif
