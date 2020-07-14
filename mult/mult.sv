`include "mips.svh"
module mult (
    input logic clk, 
    input word_t a, b,
    output dword_t hilo,
    input logic is_signed
);
    word_t A, B;
    dword_t P;
    mult_gen_0 mult_gen_0(.clk(clk), .A, .B, .P);

    assign A = (is_signed & a[31]) ? -a:a;
    assign B = (is_signed & b[31]) ? -b:b;
    assign hilo = (is_signed & (a[31] ^ b[31])) ? -P:P;
endmodule

// module CSA (parameter W = 32)(
//     input logic [W-1:0] a, b, cin,
//     output logic [W-1:0] cout, s
// );
//     assign s = a ^ b ^ cin;
//     assign cout = (a & b) | (b & cin) | (a & cin);
// endmodule