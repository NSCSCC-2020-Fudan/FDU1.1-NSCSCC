module srcbdmux (
    input word_t regfile, m, w,
    input forwardbd_t sel,
    output word_t srcb
);
    always_comb begin
        case (sel)
            M:srcb = m;
            W:srcb = w;
            D:srcb = regfile;
            default:srcb = '0;
        endcase
    end
endmodule