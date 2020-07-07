module writedata (
    input word_t rd, _wd,
    input decoded_op_t op,
    output word_t wd
);
    assign wd = (op == SB) ? {rd[31:SB_W], wd[SB_W-1:0]} : (
                (op == SH) ? {rd[31:SH_W], wd[SH_W-1:0]} : wd );
endmodule