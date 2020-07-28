`include "interface.svh"
module datapath 
    import common::*;(
    input logic clk, resetn,
    input logic[5:0] ext_int,
    
    output word_t pc,
    input word_t instr_,

    output mem_pkg::read_req_t mread,
    output mem_pkg::write_req_t mwrite,
    output rf_w_t[ISSUE_WIDTH-1:0] rfwrite,
    input word_t rd,
    output word_t[ISSUE_WIDTH-1:0] wb_pc,
    // output logic inst_en,
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
                      .self(pcselect_intf.pcselect));
    fetch fetch(.instr_, .pc,
                .freg(freg_intf.fetch),
                .dreg(dreg_intf.fetch),
                .pcselect(pcselect_intf.fetch)
                );
    decode decode(.dreg(dreg_intf.decode),
                  .rreg(rreg_intf.decode));
    renaming renaming(.self(renaming_intf.renaming),
                      .rreg(rreg_intf.renaming),
                      .ireg(ireg_intf.renaming)
                      );
    issue issue(.clk, .resetn,
                .ireg(ireg_intf.issue),
                .ereg(ereg_intf.issue),
                .wakes(wake_intf.issue),
                .payloadRAM(payloadRAM_intf.issue)
                );
    execute execute(.clk, .resetn,
                    .ereg(ereg_intf.execute),
                    .creg(creg_intf.execute),
                    .forward(forward_intf.execute),
                    .wake(wake_intf.execute),
                    .mread, .rd, .d_data_ok);
    commit commit(.creg(creg_intf.commit),
                  .self(commit_intf.commit),
                  .forward(forward_intf.commit),
                  .wake(wake_intf.commit)
                  );

    rat rat(.clk, .resetn,
            .renaming(renaming_intf.rat),
            .retire(retire_intf.rat)
            );
    rob rob(.clk, .resetn, 
            .renaming(renaming_intf.rob),
            .commit(commit_intf.rob),
            .retire(retire_intf.rob),
            .payloadRAM(payloadRAM_intf.rob),
            .hazard(hazard_intf.rob),
            .d_data_ok, .mwrite);

    freg freg(.clk, .resetn, .self(freg_intf.freg), .hazard(hazard_intf.freg));
    dreg dreg(.clk, .resetn, .self(dreg_intf.dreg), .hazard(hazard_intf.dreg));
    rreg rreg(.clk, .resetn, .self(rreg_intf.rreg), .hazard(hazard_intf.rreg));
    ireg ireg(.clk, .resetn, .self(ireg_intf.ireg), .hazard(hazard_intf.ireg));
    ereg ereg(.clk, .resetn, .self(ereg_intf.ereg), .hazard(hazard_intf.ereg));
    creg creg(.clk, .resetn, .self(creg_intf.creg), .hazard(hazard_intf.creg));

    hazard hazard(.i_data_ok, .d_data_ok, 
                  .self(hazard_intf.hazard));
    exception exception(.reset(resetn),.self(exception_intf.excep),
                        .pcselect(pcselect_intf.exception),
                        .hazard(hazard_intf.exception));
    // cp0 cp0(.clk);
    arf arf(.clk, .resetn, .retire(retire_intf.arf), .rfwrite);
    creg_select creg_select(.self(payloadRAM_intf.creg_select));
    hilo hilo(.retire(retire_intf.hilo),
              .payloadRAM(payloadRAM_intf.hilo));
    forward forward(.self(forward_intf.forward));
endmodule