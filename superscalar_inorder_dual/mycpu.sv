`include "mips.svh"

// sram
module mycpu #(
    parameter logic DO_ADDR_TRANSLATION = 1
) (
    input logic clk,
    input logic resetn,  //low active
    input logic[5:0] ext_int,  //interrupt,high active

    output logic inst_req, data_req,
    output logic inst_wr, data_wr,
    output logic [1:0] inst_size, data_size,
    output word_t inst_addr, data_addr,
    output word_t inst_wdata, data_wdata,
    input word_t inst_rdata, data_rdata,
    input logic inst_addr_ok, data_addr_ok,
    input logic inst_data_ok, data_data_ok,
    
    (*mark_debug = "true"*) output logic inst_ibus_req,
    (*mark_debug = "true"*) output word_t inst_ibus_addr,
    (*mark_debug = "true"*) input logic inst_ibus_addr_ok, inst_ibus_data_ok,
    (*mark_debug = "true"*) input logic [63: 0] inst_ibus_data,
    (*mark_debug = "true"*) input logic inst_ibus_index,

    //debug
    output word_t debug_wb_pc,
    output rwen_t debug_wb_rf_wen,
    output creg_addr_t debug_wb_rf_wnum,
    output word_t debug_wb_rf_wdata
);
    m_r_t mread;
    m_w_t mwrite;
    rf_w_t rfwrite;
    rf_w_t [1: 0] rfw_out;
    word_t [1: 0] rt_pc_out;
    logic stallF, flushE;
    logic clk_;
    // always_ff @( posedge clk) begin
    //     clk_ <=  clk & inst_addr_ok & (inst_data_ok | ~inst_req) & (data_data_ok | ~data_req) & inst_data_ok;
    // end
    assign clk_ = clk;
    word_t vaddr_d, vaddr_i;
    logic den;
    logic [1: 0] dsize; 
    word_t dwd, daddr, iaddr;
    logic dwt;
    
    datapath datapath(.clk(clk_), .reset(resetn), .ext_int, 
                      .iaddr(iaddr), .idata({32'b0, inst_rdata}), .ihit(1'b0), 
                      .idataOK(i_data_ok), .ddataOK(data_data_ok),
                      // .iaddrOK(inst_addr_ok),
                      .dwd(dwd), .den(den), .dwt(dwt), .daddr(vaddr_d), .dsize(dsize),
                      .rfw_out(rfw_out), .drd(data_rdata), .rt_pc_out(rt_pc_out),
                      .stallF_out(stallF), .flush_ex(flushE),
                      .inst_ibus_req, .inst_ibus_addr_ok, 
                      .inst_ibus_data_ok, .inst_ibus_data, .inst_ibus_index);
    
    // assign inst_req = 1'b1;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_wdata = '0;
    logic inst_req_;
//    assign inst_req = inst_req_ & d_data_ok;
    //handshake i_handshake(.clk, .reset(~resetn), .cpu_req(1'b1), .addr_ok(inst_addr_ok), .data_ok(inst_data_ok), .cpu_data_ok(i_data_ok), .req(inst_req));
    /*
    handshake i_handshake(.clk, .reset(~resetn), 
                          .cpu_req(1'b1), .addr_ok(inst_ibus_addr_ok), .data_ok(inst_ibus_data_ok), 
                          .cpu_data_ok(i_data_ok), .req(inst_ibus_req));
    */                          
    // assign data_req = (mread.ren) | (mwrite.wen);
//    assign data_req = den;
    assign data_wr = dwt;
    //assign vaddr_d = daddr;
    assign vaddr_i = iaddr;

    if (DO_ADDR_TRANSLATION == 1) begin
        always_comb begin
            case (vaddr_d[31:28])
                4'h8: data_addr[31:28] = 4'b0;
                4'h9: data_addr[31:28] = 4'b1;
                4'ha: data_addr[31:28] = 4'b0;
                4'hb: data_addr[31:28] = 4'b1;
                default: begin
                    data_addr[31:28] = vaddr_d[31:28];
                end
            endcase
            
            case (vaddr_i[31:28])
                4'h8: inst_addr[31:28] = 4'b0;
                4'h9: inst_addr[31:28] = 4'b1;
                4'ha: inst_addr[31:28] = 4'b0;
                4'hb: inst_addr[31:28] = 4'b1;
                default: begin
                    inst_addr[31:28] = vaddr_i[31:28];
                end
            endcase                        
        end
        always_comb begin
            
        end
        assign data_addr[27:0] = vaddr_d[27:0];
        assign inst_addr[27:0] = vaddr_i[27:0];
    end else begin
        // pass virtual address
        assign data_addr = vaddr_d;
        assign inst_addr = vaddr_i;
    end

    assign data_wdata = dwd;
    assign data_size = dsize;
    handshake d_handshake(.clk, .reset(resetn), 
                          .cpu_req(den), .addr_ok(data_addr_ok), .data_ok(data_data_ok), 
                          .cpu_data_ok(d_data_ok), .req(data_req));
        
    rfwrite_queue rfwrite_queue(.clk, .reset(resetn),
                                .rfw(rfw_out), .rt_pc(rt_pc_out),
                                .rfw_out(rfwrite), .rt_pc_out(debug_wb_pc));
    
    assign debug_wb_rf_wen = {4{rfwrite.wen && (rfwrite.addr != 0)}};
    assign debug_wb_rf_wnum = rfwrite.addr;
    assign debug_wb_rf_wdata = rfwrite.wd;
    
    assign inst_ibus_addr = inst_addr;
    
endmodule