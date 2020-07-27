`include "interface.svh"
module datapath 
    import common::*;(
    input logic clk, resetn,
    input logic[5:0] ext_int,
    
    output word_t pc,
    input word_t instr_,

    output mem_pkg::read_req_t mread,
    output mem_pkg::write_req_t mwrite,
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
    renaming_intf renaming_intf();
    forward_intf forward_intf();
    exception_intf exception_intf();
    wake_intf wake_intf();
    commit_intf commit_intf();
    retire_intf retire_intf();
    payloadRAM_intf payloadRAM_intf();
    hazard_intf hazard_intf();
    pcselect pcselect(.freg(freg_intf.pcselect),
                      .ports(pcselect_intf.pcselect));
    fetch fetch(.instr_, .pc,
                .freg(freg_intf.fetch),
                .dreg(dreg_intf.fetch),
                .pcselect(pcselect_intf.fetch)
                );
    decode decode(.dreg(dreg_intf.dreg),
                  .rreg(rreg_intf.rreg));
    renaming renaming(.ports(renaming_intf.renaming),
                      .rreg(rreg_intf.renaming),
                      .ireg(ireg_intf.renaming)
                      );
    issue issue(.clk, .resetn,
                .ireg(ireg_intf.issue),
                .ereg(ereg_intf.issue),
                .wake(wake_intf.issue),
                .payloadRAM(payloadRAM_intf.issue)
                );
    execute execute(.clk, .resetn,
                    .ereg(ereg_intf.execute),
                    .creg(creg_intf.execute),
                    .forward(forward_intf.execute),
                    .mread, .rd);
    commit commit(.ereg(ereg_intf.commit),
                  .self(commit_intf.commit),
                  .forward(forward_intf.commit),
                  .wake(wake_intf.commit)
                  );

    rat rat(.clk, .resetn);
    rob rob(.clk, .resetn);

    freg freg(.clk, .resetn, .ports(freg_intf.freg), .hazard(hazard_intf.freg));
    dreg dreg(.clk, .resetn, .ports(dreg_intf.dreg), .hazard(hazard_intf.dreg));
    rreg rreg(.clk, .resetn, .ports(rreg_intf.rreg), .hazard(hazard_intf.rreg));
    ireg ireg(.clk, .resetn, .ports(ireg_intf.ireg), .hazard(hazard_intf.ireg));
    ereg ereg(.clk, .resetn, .ports(ereg_intf.ereg), .hazard(hazard_intf.ereg));
    creg creg(.clk, .resetn, .ports(creg_intf.creg), .hazard(hazard_intf.creg));

    hazard hazard();
    exception exception();
    cp0 cp0(.clk, .resetn);
    arf arf(.clk, .resetn);
endmodule