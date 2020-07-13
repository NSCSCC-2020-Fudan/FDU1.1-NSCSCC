module multiplier (
    input logic[32:0]
);
    
endmodule

module CSA (parameter W = 32)(
    input logic [W-1:0] a, b, cin,
    output logic [W-1:0] cout, s
);
    assign s = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule