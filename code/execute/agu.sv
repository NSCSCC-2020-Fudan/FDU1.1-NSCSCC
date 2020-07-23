// address generate unit
module agu 
    import common::*;
    import mem_pkg::*;
    (
    input logic clk, resetn,
    input word_t src1, src2,
    input word_t wd_,
    output word_t wd
);
    read_req_t read;
    write_req_t write;

    readdata readdata(._rd(), .rd(), .addr(addr[1:0]), .op());
    writedata writedata(.addr(addr[1:0]), ._wd(), .op(), .wd());
    vaddr_t addr, addr_new;
    assign addr_new = src1 + src2;
    
    always_ff @(posedge clk) begin
        if (~resetn) begin
            addr <= '0;
        end else begin
            addr <= addr_new;
        end
    end
endmodule

module readdata (
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

module writedata (
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
                        en = 1'b1;
                        wd = _wd;
                    end 
                    1'b1: begin
                        en = 1'b1;
                        wd = {_wd[15:0], 16'b0};
                    end
                    default: begin
                        en = 'b0;
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