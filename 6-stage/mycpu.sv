`include "mips.svh"

// sram
module mycpu(
    input logic clk,
    input logic resetn,  //low active
    input logic[5:0] ext_int,  //interrupt,high active

    output logic inst_req, data_req,
    output logic inst_wr, data_wr,
    output logic [1:0]inst_size, data_size,
    output word_t inst_addr, data_addr,
    output word_t inst_wdata, data_wdata,
    input word_t inst_rdata, data_rdata,
    input logic inst_addr_ok, data_addr_ok,
    input logic inst_data_ok, data_data_ok,

    //debug
    output word_t debug_wb_pc,
    output rwen_t debug_wb_rf_wen,
    output creg_addr_t debug_wb_rf_wnum,
    output word_t debug_wb_rf_wdata
);
    m_r_t mread;
    m_w_t mwrite;
    rf_w_t rfwrite;
    logic stallF, flush_ex;
    logic clk_;
    // always_ff @( posedge clk) begin
    //     clk_ <=  clk & inst_addr_ok & (inst_data_ok | ~inst_req) & (data_data_ok | ~data_req) & inst_data_ok;
    // end
    assign clk_ = clk;
    word_t vaddr;
    logic i_data_ok, d_data_ok;
    datapath datapath(.clk(clk_), .resetn, .ext_int, 
                      .pc(inst_addr), .instr_(inst_rdata),
                      .mread, .mwrite, .rfwrite, .rd(data_rdata), .wb_pc(debug_wb_pc),
                      .stallF, .flush_ex,
                      .i_data_ok(inst_data_ok), .d_data_ok, 
                      .i_addr_ok(inst_addr_ok), .d_addr_ok(data_addr_ok));
    assign inst_req = 1'b1;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_wdata = '0;
    logic inst_req_;
    // assign inst_req = inst_req_ & d_data_ok;
    // handshake i_handshake(.clk, .resetn, .cpu_req(1'b1), .addr_ok(inst_addr_ok), .data_ok(inst_data_ok), .cpu_data_ok(i_data_ok), .req(inst_req));
    // assign data_req = (|mread.ren) | (|mwrite.wen);
    assign data_wr = mwrite.wen;
    assign vaddr = (mwrite.wen) ? mwrite.addr : mread.addr;
    // always_comb begin
    //     case (vaddr[31:28])
    //         4'h8: data_addr[31:28] = 4'b0;
    //         4'h9: data_addr[31:28] = 4'b1;
    //         4'ha: data_addr[31:28] = 4'b0;
    //         4'hb: data_addr[31:28] = 4'b1;
    //         default: begin
    //             data_addr[31:28] = vaddr[31:28];
    //         end
    //     endcase
    // end
    // always_comb begin
        
    // end
    // assign data_addr[27:0] = vaddr[27:0];
    assign data_addr = vaddr;
    assign data_wdata = mwrite.wd;
    assign data_size = mwrite.wen ? mwrite.size : mread.size;
    handshake d_handshake(.clk, .resetn, .cpu_req(mread.ren|mwrite.wen), .addr_ok(data_addr_ok), .data_ok(data_data_ok), .cpu_data_ok(d_data_ok), .req(data_req));

    assign debug_wb_rf_wen = {4{rfwrite.wen && (rfwrite.addr != 0)}};
    assign debug_wb_rf_wnum = rfwrite.addr;
    assign debug_wb_rf_wdata = rfwrite.wd;
endmodule