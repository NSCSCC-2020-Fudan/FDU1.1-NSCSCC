`include "mips.svh"

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