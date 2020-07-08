`include "mips.svh"

module writedata (
    input logic[1:0] addr,
    input word_t _wd,
    input decoded_op_t op,
    output m_wen_t en,
    output word_t wd
);
    always_comb begin
        case (op)
            SW : begin
                en = 4'b1111;
                wd = _wd;
            end 
            SH: begin
                case (addr[1])
                    1'b0: begin
                        en = 4'b0011;
                        wd = _wd;
                    end 
                    1'b1: begin
                        en = 4'b1100;
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
                        en = 4'b0001;
                        wd = _wd;
                    end 
                    2'b01: begin
                        en = 4'b0010;
                        wd = {_wd[23:0], 8'b0};
                    end 
                    2'b10: begin
                        en = 4'b0100;
                        wd = {_wd[15:0], 16'b0};
                    end 
                    2'b11: begin
                        en = 4'b1000;
                        wd = {_wd[7:0], 24'b0};
                    end 
                    default: begin
                        en = 'b0;
                        wd = 'b0;
                    end
                endcase
            end
            default: begin
                en = '0;
                wd = '0;
            end
        endcase
    end
endmodule


// module writedata (
//     input word_t rd, _wd, wa,
//     input decoded_op_t op,
//     output word_t wd
// );
//     always_comb begin
//         case (op)
//             SB: begin
//                 case (wa[1:0])
//                     2'b00: wd = {rd[31:8], _wd[7:0]};
//                     2'b01: wd = {rd[31:15], _wd[7:0], rd[7:0]};
//                     2'b10: wd = {rd[31:24], _wd[7:0], rd[15:0]};
//                     2'b11: wd = {_wd[7:0], rd[23:0]};
//                     default: wd = _wd;
//                 endcase
//             end
//             SH: begin
//                 case (wa[1])
//                     1'b0: wd = {rd[31:15], _wd[15:0]};
//                     1'b1: wd = {_wd[15:0], rd[15:0]};
//                     default: begin
//                         wd = _wd;
//                     end
//                 endcase
//             end
//             default: begin
//                 wd = _wd;
//             end
//         endcase
//     end
//endmodule