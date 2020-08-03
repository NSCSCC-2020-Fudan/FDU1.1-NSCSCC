module multiplier 
    import common::*;(
    input logic clk, 
    input word_t a, b,
    output dword_t hilo,
    input logic is_signed
);
    word_t A, B;
    dword_t P;
    mult_gen_0 mult_gen_0(.CLK(clk), .A, .B, .P);

    assign A = (is_signed & a[31]) ? -a:a;
    assign B = (is_signed & b[31]) ? -b:b;
    assign hilo = (is_signed & (a[31] ^ b[31])) ? -P:P;
endmodule