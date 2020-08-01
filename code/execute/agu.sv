// address generate unit
module mem 
    import common::*;
    import decode_pkg::*;
    import issue_pkg::*;
    import commit_pkg::*;
    (
    input logic clk, resetn, flush, 
    input word_t src1, src2,
    input word_t rd_, wd_,
    input issued_instr_t mem_issue,
    input logic d_data_ok,
    output mem_commit_t mem_commit,
    output m_r_t mread
);
    vaddr_t addr_1, addr_2;
    assign addr_1 = src1 + src2;
    word_t wd_2;
    issued_instr_t mem_issue_2;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            addr_2 <= '0; 
            mem_issue_2 <= '0;
            wd_2 <= '0;
        end else if (d_data_ok | ~mem_issue_2.ctl.memtoreg) begin
            addr_2 <= addr_1;
            mem_issue_2 <= mem_issue;
            wd_2 <= wd_;
        end
    end

    word_t rd, wd;
    readdata readdata(._rd(rd_), .rd, .addr(addr_2[1:0]), .op(mem_issue_2.op));
    writedata writedata(.addr(addr_2[1:0]), ._wd(wd_2), .op(mem_issue_2.op), .wd);

    assign mem_commit.valid = mem_issue_2.valid & (d_data_ok | ~mem_issue_2.ctl.memtoreg);
    assign mem_commit.data = mem_issue_2.ctl.memtoreg ? rd : wd;
    assign mem_commit.addr = addr_2;
    assign mem_commit.rob_addr = mem_issue_2.dst;
    always_comb begin
        mem_commit.exception = mem_issue_2.exception;
        mem_commit.exception.load = ((mem_issue_2.op == LW) && (addr_2[1:0] != '0)) ||
                            ((mem_issue_2.op == LH || mem_issue_2.op == LHU) && (addr_2[0] != '0));
        mem_commit.exception.save = ((mem_issue_2.op == SW) && (addr_2[1:0] != '0)) ||
                            ((mem_issue_2.op == SH) && (addr_2[0] != '0));
    end

    assign mread.ren = mem_issue_2.ctl.memtoreg & ~mem_commit.exception.load;
    assign mread.addr = addr_2;
    assign mread.size = mem_issue_2.op == LW ? 2'b10 : (
                        mem_issue_2.op == LH ? 2'b01 : 2'b00
    );
endmodule

module readdata 
    import common::*;
    import decode_pkg::*;(
    input word_t _rd,
    output word_t rd,
    input logic[1:0] addr,
    input decoded_op_t op
);
    always_comb begin
        case (op)
            LB: begin
                case (addr)
                    2'b00: rd = {{24{_rd[7]}}, _rd[7:0]};
                    2'b01: rd = {{24{_rd[15]}}, _rd[15:8]};
                    2'b10: rd = {{24{_rd[23]}}, _rd[23:16]};
                    2'b11: rd = {{24{_rd[31]}}, _rd[31:24]};
                    default: rd = _rd;
                endcase
            end
            LBU: begin
                case (addr)
                    2'b00: rd = {24'b0, _rd[7:0]};
                    2'b01: rd = {24'b0, _rd[15:8]};
                    2'b10: rd = {24'b0, _rd[23:16]};
                    2'b11: rd = {24'b0, _rd[31:24]};
                    default: rd = _rd;
                endcase
            end
            LH: begin
                case (addr[1])
                    1'b0: rd = {{16{_rd[15]}}, _rd[15:0]};
                    1'b1: rd = {{16{_rd[31]}}, _rd[31:16]};
                    default: begin
                        rd = _rd;
                    end
                endcase
            end
            LHU: begin
                case (addr[1])
                    1'b0: rd = {16'b0, _rd[15:0]};
                    1'b1: rd = {16'b0, _rd[31:16]};
                    default: begin
                        rd = _rd;
                    end
                endcase
            end
            default: begin
                rd = _rd;
            end
        endcase
    end
endmodule

module writedata 
    import common::*;
    import decode_pkg::*;(
    input logic[1:0] addr,
    input word_t _wd,
    input decoded_op_t op,
    output word_t wd
);
    always_comb begin
        case (op)
            SW : begin
                wd = _wd;
            end 
            SH: begin
                case (addr[1])
                    1'b0: begin
                        wd = _wd;
                    end 
                    1'b1: begin
                        wd = {_wd[15:0], 16'b0};
                    end
                    default: begin
                        wd = 'b0;
                    end
                endcase
            end
            SB: begin
                case (addr)
                    2'b00: begin
                        wd = _wd;
                    end 
                    2'b01: begin
                        wd = {_wd[23:0], 8'b0};
                    end 
                    2'b10: begin
                        wd = {_wd[15:0], 16'b0};
                    end 
                    2'b11: begin
                        wd = {_wd[7:0], 24'b0};
                    end 
                    default: begin
                        wd = 'b0;
                    end
                endcase
            end
            default: begin
                wd = '0;
            end
        endcase
    end
endmodule