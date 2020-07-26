`include "mips.svh"

module writedata_format (
        input exec_data_t in,
        output m_q_t out
    );
    
    op_t op;
    assign op = in.instr.op;
    logic [1: 0] dmem_size_w, dmem_size_r;
    assign dmem_size_w = (op == SW) ? 2'b10 : (op == SH ? 2'b01:2'b00);
    assign dmem_size_r = (op == LW) ? 2'b10 : (op == LH ? 2'b01:2'b00);
    
    logic ren, wen;
    assign ren = in.instr.ctl.memtoreg;
    assign out.size = (wen) ? (dmem_size_w) : (dmem_size_r); 
    assign out.en = wen | ren;
    assign out.addr = in.result;
    
    logic [1: 0] addr;
    assign addr = out.addr[1: 0];
    word_t _wd, wd;
    assign _wd = in.srcb;
    assign out.wd = wd;
    assign out.wt = in.instr.ctl.memwrite;
    
    always_comb begin
        case (op)
            SW : begin
                wen = 1'b1;
                wd = _wd;
            end 
            SH: begin
                case (addr[1])
                    1'b0: begin
                        wen = 1'b1;
                        wd = _wd;
                    end 
                    1'b1: begin
                        wen = 1'b1;
                        wd = {_wd[15:0], 16'b0};
                    end
                    default: begin
                        wen = 'b0;
                        wd = '0;
                    end
                endcase
            end
            SB: begin
                case (addr)
                    2'b00: begin
                        wen = 1'b1;
                        wd = _wd;
                    end 
                    2'b01: begin
                        wen = 1'b1;
                        wd = {_wd[23:0], 8'b0};
                    end 
                    2'b10: begin
                        wen = 1'b1;
                        wd = {_wd[15:0], 16'b0};
                    end 
                    2'b11: begin
                        wen = 1'b1;
                        wd = {_wd[7:0], 24'b0};
                    end 
                    default: begin
                        wen = 'b0;
                        wd = '0;
                    end
                endcase
            end
            default: begin
                wen = '0;
                wd = '0;
            end
        endcase
    end
endmodule
