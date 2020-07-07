module writedata (
    input word_t rd, _wd, wa,
    input decoded_op_t op,
    output word_t wd
);
    always_comb begin
        case (op)
            SB: begin
                case (wa[1:0])
                    2'b00: wd = {rd[31:8], _wd[7:0]};
                    2'b01: wd = {rd[31:15], _wd[7:0], rd[7:0]};
                    2'b10: wd = {rd[31:24], _wd[7:0], rd[15:0]};
                    2'b11: wd = {_wd[7:0], rd[23:0]};
                    default: wd = _wd;
                endcase
            end
            SH: begin
                case (wa[1])
                    1'b0: wd = {rd[31:15], _wd[15:0]};
                    1'b1: wd = {_wd[15:0], rd[15:0]};
                    default: begin
                        wd = _wd;
                    end
                endcase
            end
            default: begin
                wd = _wd;
            end
        endcase
    end
endmodule