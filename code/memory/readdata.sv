module readdata (
    input word_t _rd,
    output logic rd,
    input decoded_op_t op
);
    always_comb begin
        case (op)
            LB: rd = {{24{_rd[7]}}, _rd[7:0]};
            LBU:rd = {24'b0, _rd[7:0]};
            LH: rd = {{16{_rd[15]}}, _rd[15:0]};
            LHU:rd = {16'b0, _rd[15:0]};
            default: begin
                rd <= _rd;
            end
        endcase
    end
endmodule