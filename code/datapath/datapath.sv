`include "mips.svh"

module datapath (
    input logic clk, reset,
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
    // always_ff @(posedge clk, posedge reset) begin
    //     if (reset) begin
    //         i_data_ok <= '0;
    //     end else begin
    //         i_data_ok <= 1'b1;
    //     end
    // end
    pcselect_freg_fetch pcselect_freg_fetch(.pc(pc));
    fetch_dreg_decode fetch_dreg_decode(.instr_);
    decode_ereg_exec decode_ereg_exec();
    exec_mreg_memory exec_mreg_memory();
    memory_dram memory_dram(.rd, .mread, .mwrite);
    memory_wreg_writeback memory_wreg_writeback();
    regfile_intf regfile_intf(.rfwrite);
    hilo_intf hilo_intf();
    cp0_intf cp0_intf();
    hazard_intf hazard_intf(.i_data_ok, .stallF, .d_data_ok, .flush_ex);
    exception_intf exception_intf(.ext_int);
    pcselect_intf pcselect_intf();
    
    Freg freg(.ports(pcselect_freg_fetch.freg), 
               .clk, .reset, .hazard(hazard_intf.freg));
    fetch fetch(.in(pcselect_freg_fetch.fetch), 
                 .out(fetch_dreg_decode.fetch), 
                 .pcselect(pcselect_intf.fetch),
                 .clk, .reset);
    pcselect pcselect(.out(pcselect_freg_fetch.pcselect),
                       .in(pcselect_intf.pcselect), .clk, .reset);
    
    Dreg dreg(.clk, .reset, 
               .ports(fetch_dreg_decode.dreg),
               .hazard(hazard_intf.dreg));
    decode decode(.in(fetch_dreg_decode.decode),
                   .out(decode_ereg_exec.decode),
                   .regfile(regfile_intf.decode),
                   .hilo(hilo_intf.decode),
                   .cp0(cp0_intf.decode),
                   .hazard(hazard_intf.decode),
                   .pcselect(pcselect_intf.decode));
    
    Ereg ereg(.clk, .reset, 
               .ports(decode_ereg_exec.ereg),
               .hazard(hazard_intf.ereg));
    execute execute(.in(decode_ereg_exec.exec),
                     .out(exec_mreg_memory.exec),
                     .hazard(hazard_intf.exec));
    
    Mreg mreg0(.clk, .reset,
               .ports(exec_mreg_memory.mreg),
               .hazard(hazard_intf.mreg));
    memory memory0(.in(exec_mreg_memory.memory),
                   .out(memory_wreg_writeback.memory),
                   .hazard(hazard_intf.memory),
                   .exception(exception_intf.memory),
                   .dram(memory_dram.memory),
                   .cp0(cp0_intf.memory));
    
    Wreg wreg0(.clk, .reset,
               .ports(memory_wreg_writeback.wreg),
               .hazard(hazard_intf.wreg));
    writeback writeback0(.pc(wb_pc),
                         .in(memory_wreg_writeback.writeback),
                         .regfile(regfile_intf.writeback),
                         .hilo(hilo_intf.writeback),
                         .cp0(cp0_intf.writeback),
                         .hazard(hazard_intf.writeback));

    // regfile interacts with Decode, Writeback
    regfile regfile0(.ports(regfile_intf.regfile), .clk, .reset);

    // hilo interacts with Decode, Writeback
    hilo hilo0(.ports(hilo_intf.hilo),.clk, .reset);

    // cp0 interacts with memory, exception
    cp0 cp0(.ports(cp0_intf.cp0),
             .excep(exception_intf.cp0),
             .clk, .reset,
             .pcselect(pcselect_intf.cp0));

    // hazard interacts with Freg, Dreg, Ereg, Mreg, Wreg, Decode, Execute, Memory
    hazard hazard0(.ports(hazard_intf.hazard),.pcselect(pcselect_intf.hazard), .clk, .reset);

    // exception interacts with cp0, pcselect, memory
    exception exception(.ports(exception_intf.excep),
                        .pcselect(pcselect_intf.excep),
                        .hazard(hazard_intf.excep),
                        .reset);
endmodule