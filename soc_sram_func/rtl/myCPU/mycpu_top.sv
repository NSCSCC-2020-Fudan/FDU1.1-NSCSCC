`include "mips.svh"

// sram
module mycpu_top(
    input logic clk,
    input logic resetn,  //low active
    input logic[5:0] ext_int,  //interrupt,high active

    output logic inst_sram_en,
    output rwen_t inst_sram_wen,
    output word_t inst_sram_addr,
    output word_t inst_sram_wdata,
    input word_t inst_sram_rdata,
    
    output logic data_sram_en,
    output rwen_t data_sram_wen,
    output word_t data_sram_addr,
    output word_t data_sram_wdata,
    input word_t data_sram_rdata,

    //debug
    output word_t debug_wb_pc,
    output rwen_t debug_wb_rf_wen,
    output creg_addr_t debug_wb_rf_wnum,
    output word_t debug_wb_rf_wdata
);
    m_r_t mread;
    m_w_t mwrite;
    rf_w_t rfwrite;
    datapath datapath(.clk, .reset(~resetn), .ext_int, 
                      .pc(inst_sram_addr), .instr(inst_sram_rdata),
                      .mread, .mwrite, .rfwrite, .rd(data_sram_rdata), .wb_pc(debug_wb_pc));

    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = '0;

    assign data_sram_en = | (mread.men | mwrite.wen);
    assign data_sram_wen = mwrite.wen;
    assign data_sram_addr = (|mwrite.wen) ? mwrite.addr : mread.addr;
    assign data_sram_wdata = mwrite.wd;
    assign debug_wb_rf_wen = {4{rfwrite.wen}};
    assign debug_wb_rf_wnum = rfwrite.addr;
    assign debug_wb_rf_wdata = rfwrite.wd;
endmodule


// axi
// module mycpu_top (
//         .ext_int   (6'd0          ),   //high active

//     .aclk      (cpu_clk       ),
//     .aresetn   (cpu_resetn    ),   //low active

//     .arid      (cpu_arid      ),
//     .araddr    (cpu_araddr    ),
//     .arlen     (cpu_arlen     ),
//     .arsize    (cpu_arsize    ),
//     .arburst   (cpu_arburst   ),
//     .arlock    (cpu_arlock    ),
//     .arcache   (cpu_arcache   ),
//     .arprot    (cpu_arprot    ),
//     .arvalid   (cpu_arvalid   ),
//     .arready,
                
//     .rid,
//     .rdata,
//     .rresp,
//     .rlast,
//     .rvalid,
//     .rready,
               
//     .awid,
//     .awaddr,
//     .awlen,
//     .awsize,
//     .awburst,
//     .awlock,
//     .awcache,
//     .awprot,
//     .awvalid,
//     .awready,
    
//     .wid,
//     .wdata,
//     .wstrb,
//     .wlast,
//     .wvalid,
//     .wready,
    
//     .bid,
//     .bresp,
//     .bvalid,
//     .bready,

//     //debug interface
//     .debug_wb_pc,
//     .debug_wb_rf_wen,
//     .debug_wb_rf_wnum,
//     .debug_wb_rf_wdata
// );
    
// endmodule