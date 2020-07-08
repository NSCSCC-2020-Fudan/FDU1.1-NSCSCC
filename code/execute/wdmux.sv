module wdmux (
    input word_t e, m, w,
    input forwardbe_t sel,
    output word_t srcb0
);
    always_comb begin
        case (sel)
            M:srcb0 = m;
            W:srcb0 = w;
            E:srcb0 = e;
            default:srcb0 = '0;
        endcase
    end
endmodule