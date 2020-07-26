`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

interface dreg_intf();
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

interface ireg_intf();
    import renaming_pkg::*;

    renaming_data_t [MACHINE_WIDTH-1:0]dataR, dataR_new;
    modport renaming(
        output dataR_new
    );
    modport ireg(
        input dataR_new, 
        output dataR
    );
    modport issue(
        input dataR
    );
endinterface

interface ereg_intf();
    import issue_pkg::*;

    issue_data_t dataI, dataI_new;
    modport issue(
        output dataI_new
    );
    modport ereg(
        input dataI_new,
        output dataI
    );
    modport execute(
        input dataI
    );
endinterface

interface creg_intf();
    import execute_pkg::*;

    execute_data_t dataE, dataE_new;
    modport execute(
        output dataE_new
    );
    modport creg(
        input dataE_new,
        output dataE
    );
    modport commit(
        input dataE
    );
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

interface payloadRAM_intf();
    word_t []
endinterface

interface renaming_intf();
    import common::*;
    rob_pkg::rob_addr_t [MACHINE_WIDTH-1:0]rob_addr_new;
    exception::exception_t[MACHINE_WIDTH-1:0] exception;
    word_t [MACHINE_WIDTH-1:0]pcplus8;
    creg_addr_t [MACHINE_WIDTH-1:0]dst;

    modport renaming(
        input
        output exception, pcplus8, dst,
    );
    modport rat(
        input rob_addr_new,
        output rob_addr_old
    );
    modport rob(
        input exception, pcplus8, dst,
        input rob_addr_old,
        output rob_addr_new
    );
endinterface

interface retire_intf();
    modport rat(
        input
        output
    );
    modport rob(
        input
        output
    );
    modport arf(
        input
        output
    );
endinterface

interface commit_intf();
    modport commit(
        input
        output
    );
    modport rob(
        input
        output
    );
endinterface

interface wake_intf();
    modport issue(
        input
        output
    );
    modport execute(
        input
        output
    );
    modport commit(
        input
        output
    );
endinterface

interface arf_intf();
    import common::*;
    import regfile_pkg::*;

    r_req_t [AREG_READ_PORTS-1:0] r_req;
    r_resp_t [AREG_READ_PORTS-1:0] r_resp;
    w_req_t [AREG_WRITE_PORTS-1:0] w_req;
endinterface

interface exception_intf();
    import common::*;
    import exception_pkg::*;

endinterface

`endif
