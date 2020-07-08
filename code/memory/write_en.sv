module write_en (
    input logic[1:0] addr,
    input decoded_op_t op,
    output m_wen_t en
);
    always_comb begin
        case (op)
            SW : en = 4'b1111;
            SH: begin
                case (addr[1])
                    1'b0: en = 4'b0011;
                    1'b1: en = 4'b1100;
                    default: begin
                        en = 'b0;
                    end
                endcase
            end
            SB: begin
                case (addr)
                    2'b00: en = 4'b0001;
                    2'b01: en = 4'b0010;
                    2'b10: en = 4'b0100;
                    2'b11: en = 4'b1000;
                    default: begin
                        en = 'b0;
                    end
                endcase
            end
            default: begin
                en = '0;
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
endmodule