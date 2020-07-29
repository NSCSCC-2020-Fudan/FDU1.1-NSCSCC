`ifndef __INTERFACE_SVH
`define __INTERFACE_SVH

interface freg_intf();
    import common::*;
    word_t pc, pc_new;
    modport pcselect(output pc_new);
    modport freg(output pc, input pc_new);
    modport fetch(input pc);
endinterface

interface dreg_intf();
    import common::*;
    import fetch_pkg::*;
    fetch_data_t [MACHINE_WIDTH-1:0]dataF, dataF_new;
    modport fetch(output dataF_new);
    modport dreg(input dataF_new, output dataF);
    modport decode(input dataF);
endinterface // dreg_intf

interface rreg_intf();
    import common::*;
    import decode_pkg::*;
    
    decode_data_t [MACHINE_WIDTH-1:0]dataD, dataD_new;
    modport decode(output dataD_new);
    modport rreg(input dataD_new, output dataD);
    modport renaming(input dataD);
endinterface

interface ireg_intf();
    import common::*;
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
    import common::*;
    word_t [MACHINE_WIDTH-1:0] arf1, arf2;
    struct packed {
        logic valid;
        word_t data;
    } [MACHINE_WIDTH-1:0] prf1, prf2;
    word_t [MACHINE_WIDTH-1:0] cp01, cp02, hi, lo;
    creg_addr_t [MACHINE_WIDTH-1:0] creg1, creg2;
    preg_addr_t [MACHINE_WIDTH-1:0] preg1, preg2; 
    word_t [MACHINE_WIDTH-1:0] cdata1, cdata2;
    modport issue(
        input  cdata1, cdata2,
        output arf1, arf2, prf1, prf2
    );
    // prf
    modport rob(
        input preg1, preg2,
        output prf1, prf2
    );
    // arf
    modport arf(
        input creg1, creg2,
        output arf1, arf2
    );
    // cp0
    modport cp0(
        input creg1, creg2,
        output cp01, cp02
    );
    // hilo
    modport hilo(
        output hi, lo
    );
    // selection
    modport creg_select(
        input creg1, creg2,
        input arf1, arf2, cp01, cp02, hi, lo,
        output cdata1, cdata2
    );
endinterface

interface renaming_intf();
    import common::*;
    import decode_pkg::*;
    preg_addr_t [MACHINE_WIDTH-1:0]rob_addr_new;
    struct packed {
        logic valid;
        creg_addr_t src1, src2, dst;
        word_t pcplus8;
        control_t ctl;
    } [MACHINE_WIDTH-1:0]instr;
    struct packed {
        struct packed {
            logic valid;
            preg_addr_t id;
        } src1, src2, dst;
    } [MACHINE_WIDTH-1:0]renaming_info;
    modport renaming(
        input renaming_info, rob_addr_new,
        output instr
    );
    modport rat(
        input rob_addr_new, instr, 
        output renaming_info
    );
    modport rob(
        input instr,
        output rob_addr_new
    );
endinterface

interface retire_intf
    import common::*;(output word_t[ISSUE_WIDTH-1:0] wb_pc);
    import decode_pkg::*;
    struct packed {
        logic valid;
        union packed {
            dword_t data;
            struct packed {
                word_t hi;
                word_t lo;
            } hilo;
        } data;
        control_t ctl;
        creg_addr_t dst;
        preg_addr_t preg;
    } [ISSUE_WIDTH-1:0]retire;
    modport rat(
        input retire
    );
    modport rob(
        output retire, wb_pc
    );
    modport arf(
        input retire
    );
    modport cp0(
        input retire
    );
    modport hilo(
        input retire
    );
endinterface

interface commit_intf();
    import common::*;
    import commit_pkg::*;
    import execute_pkg::*;
    alu_commit_t [ALU_NUM-1:0] alu_commit;
    mem_commit_t [MEM_NUM-1:0] mem_commit;
    branch_commit_t [BRU_NUM-1:0] branch_commit;
    mult_commit_t [MULT_NUM-1:0] mult_commit;
    modport commit(
        output alu_commit, mem_commit, branch_commit, mult_commit
    );
    modport rob(
        input alu_commit, mem_commit, branch_commit, mult_commit
    );
endinterface

interface wake_intf();
    import common::*;
    import execute_pkg::*;
    import issue_queue_pkg::*;
    wake_req_t [ISSUE_WIDTH-1:0] dst_commit;
    wake_req_t [ALU_NUM-1:0] dst_execute;
    word_t [ISSUE_WIDTH-1:0] broadcast;
    modport issue(
        input dst_commit, dst_execute, broadcast
    );
    modport execute(
        output dst_execute
    );
    modport commit(
        output dst_commit, broadcast
    );
endinterface

interface exception_intf();
    import common::*;
    import exception_pkg::*;
    exception_t exception;
    modport excep(
        output exception
    );
    modport cp0(
        input exception
    );
endinterface

interface pcselect_intf();
    import common::*;
    logic branch_taken, exception_valid;
    word_t pcplus4, pcbranch, pcexception, epc;
    logic is_eret;
    modport pcselect(input pcplus4, pcbranch, pcexception, exception_valid, branch_taken);
    modport fetch(output pcplus4);
    modport rob(output branch_taken, pcbranch);
    modport exception(output exception_valid, pcexception);
    modport cp0(output epc, is_eret);
endinterface

interface hazard_intf();
    logic stallF, stallD, stallR, stallI, stallE, stallC;
    logic         flushD, flushR, flushI, flushE, flushC;
    logic branch_taken, exception_valid, is_eret, rob_full;
    modport hazard(
        input branch_taken, exception_valid, is_eret, rob_full,
        output stallF, stallD, stallR, stallI, stallE, stallC,
               flushD, flushR, flushI, flushE, flushC
    );
    modport freg(
        input stallF
    );
    modport dreg(
        input stallD, flushD
    );
    modport rreg(
        input stallR, flushR
    );
    modport ireg(
        input stallI, flushI
    );
    modport ereg(
        input stallE, flushE
    );
    modport creg(
        input stallC, flushC
    );
    modport exception(
        input exception_valid
    );
    modport rob(
        output rob_full, branch_taken
    );
endinterface

`endif
