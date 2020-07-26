`include "interface.svh"
module datapath 
    import common::*;(
    input logic clk, resetn,
    input logic[5:0] ext_int,
    
    output word_t pc,
    input word_t instr_,

    output m_r_t mread,
    output m_w_t mwrite,
    output rf_w_t rfwrite,
    input word_t rd,
    output word_t wb_pc,
    // output logic inst_en,
    output stallF, flush_ex,
    input i_data_ok, d_data_ok
);
    freg_intf freg_intf();
    dreg_intf dreg_intf();
    rreg_intf rreg_intf();
    ireg_intf ireg_intf();
    ereg_intf ereg_intf();
    creg_intf creg_intf();

    pcselect_intf pcselect_intf();

    forward_intf forward_intf();

    pcselect pcselect(.freg(freg_intf.pcselect),
                      .ports(pcselect_intf.pcselect));
    fetch fetch(.instr_, .pc,
                .freg(freg_intf.fetch),
                .dreg(dreg_intf.fetch),
                .pcselect(pcselect_intf.fetch)
                );
    decode decode(.dreg(dreg_intf.dreg),
                  .rreg(rreg_intf.rreg));
    renaming renaming();
    issue issue();
    execute execute();
    commit commit();

    rat rat(.clk, .resetn);
    rob rob(.clk, .resetn);

    freg freg(.clk, .resetn, .ports(freg_intf.freg));
    dreg dreg(.clk, .resetn, .ports(dreg_intf.dreg));
    rreg rreg(.clk, .resetn, .ports(rreg_intf.rreg));
    ireg ireg(.clk, .resetn, .ports(ireg_intf.ireg));
    ereg ereg(.clk, .resetn, .ports(ereg_intf.ereg));
    creg creg(.clk, .resetn, .ports(creg_intf.creg));
endmodule