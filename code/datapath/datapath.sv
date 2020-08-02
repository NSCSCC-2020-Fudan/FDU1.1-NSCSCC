`include "interface.svh"
module datapath 
    import common::*;(
    input logic clk, resetn,
    input logic[5:0] ext_int,
    
    output word_t pc,
    input word_t instr_,

    output m_r_t mread,
    output m_w_t mwrite,
    output rf_w_t[ISSUE_WIDTH-1:0] rfwrite,
    input word_t rd,
    output word_t[ISSUE_WIDTH-1:0] wb_pc,
    // output logic inst_en,
    input i_data_ok, d_data_ok
);
    logic flush;
    logic mult_ok;
    freg_intf freg_intf();
    dreg_intf dreg_intf();
    rreg_intf rreg_intf();
    ireg_intf ireg_intf();
    ereg_intf ereg_intf();
    creg_intf creg_intf();
    mem_ctrl_intf mem_ctrl_intf();

    pcselect_intf pcselect_intf();
    renaming_intf renaming_intf();
    forward_intf forward_intf();
    exception_intf exception_intf();
    wake_intf wake_intf();
    commit_intf commit_intf();
    retire_intf retire_intf(.wb_pc);
    payloadRAM_intf payloadRAM_intf();
    hazard_intf hazard_intf();
    cp0_intf cp0_intf();
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
    issue issue(.clk, .resetn, .flush, 
                .ireg(ireg_intf.issue),
                .ereg(ereg_intf.issue),
                .wakes(wake_intf.issue),
                .payloadRAM(payloadRAM_intf.issue),
                .mem_ctrl(mem_ctrl_intf.issue),
                .hazard(hazard_intf.issue),
                .mult_ok
                );
    execute execute(.clk, .resetn, .flush, 
                    .ereg(ereg_intf.execute),
                    .creg(creg_intf.execute),
                    .forward(forward_intf.execute),
                    .wake(wake_intf.execute),
                    .mread, .rd, .d_data_ok, .mult_ok);
    commit commit(.creg(creg_intf.commit),
                  .self(commit_intf.commit),
                  .forward(forward_intf.commit),
                  .wake(wake_intf.commit)
                  );

    rat rat(.clk, .resetn, .flush, 
            .renaming(renaming_intf.rat),
            .retire(retire_intf.rat)
            );
    rob rob(.clk, .resetn, .flush, 
            .renaming(renaming_intf.rob),
            .commit(commit_intf.rob),
            .retire(retire_intf.rob),
            .payloadRAM(payloadRAM_intf.rob),
            .hazard(hazard_intf.rob),
            .pcselect(pcselect_intf.rob),
            .d_data_ok, .mwrite,
            .exception(exception_intf.rob)
            );

    freg freg(.clk, .resetn, .self(freg_intf.freg), .hazard(hazard_intf.freg));
    dreg dreg(.clk, .resetn, .self(dreg_intf.dreg), .hazard(hazard_intf.dreg));
    rreg rreg(.clk, .resetn, .self(rreg_intf.rreg), .hazard(hazard_intf.rreg));
    ireg ireg(.clk, .resetn, .self(ireg_intf.ireg), .hazard(hazard_intf.ireg));
    ereg ereg(.clk, .resetn, .self(ereg_intf.ereg), .hazard(hazard_intf.ereg));
    creg creg(.clk, .resetn, .self(creg_intf.creg), .hazard(hazard_intf.creg));

    hazard hazard(.i_data_ok, .d_data_ok, .flush, 
                  .self(hazard_intf.hazard));
    exception exception(.resetn,.self(exception_intf.excep),
                        .pcselect(pcselect_intf.exception),
                        .hazard(hazard_intf.exception));
    cp0 cp0(.clk, .resetn, .self(cp0_intf.cp0),
            .excep(exception_intf.cp0 ),
            .pcselect(pcselect_intf.cp0),
            .payloadRAM(payloadRAM_intf.cp0),
            .retire(retire_intf.cp0));
    arf arf(.clk, .resetn, .retire(retire_intf.arf), .rfwrite, .payloadRAM(payloadRAM_intf.arf));
    creg_select creg_select(.self(payloadRAM_intf.creg_select));
    hilo hilo(.clk, .resetn, .retire(retire_intf.hilo),
              .payloadRAM(payloadRAM_intf.hilo));
    forward forward(.self(forward_intf.forward));

    mem_ctrl mem_ctrl(.clk, .resetn, .flush, .d_data_ok, 
                      .ren(mread.ren),
                      .wen(mwrite.wen),
                      .self(mem_ctrl_intf.mem_ctrl));
endmodule