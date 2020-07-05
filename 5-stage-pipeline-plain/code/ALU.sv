module ALU(
        input logic [31: 0] a, b,
        input logic [4: 0] ALUCtrl,
        output logic [31: 0] c, d
        output logic OverflowExpection
    );
    
    logic [32: 0] tmp;
    logic [63: 0] mul;
    always @(*)
        case (ALUCtrl[3, 1])
            4'b0000:
                begin
                    if (!ALUCtrl[0])
                        begin
                            tmp <= {a[31], a} + {b[31], b};
                            OverflowExpection = (tmp[32] != tmp[31]);
                            c = tmp[31: 0]; 
                        end
                    else 
                        c = a + b;
                end
            4'b0001:
                begin
                    if (!ALUCtrl[0])
                        begin
                            tmp <= {a[31], a} - {b[31], b};
                            OverflowExpection = (tmp[32] != tmp[31]);
                            c = tmp[31: 0]; 
                        end
                    else 
                        c = a - b;
                end
            4'b0010:
                c = (ALU[0]) ? (signed(a) < signed(b)) : (a < b);
            4'b0011:
                begin
                    c = (ALU[0]) ? (signed(a) div signed(b)) : (a div b);
                    c = (ALU[0]) ? (signed(a) mod signed(b)) : (a mod b);
                end
            4'b0100:
                begin
                    mul <= signed(a) * signed(b);
                    c = mul[63: 32];
                    d = mul[31: 0];
                end
            4'b0101:
                c = a & b;
            4'b0110:
                c = a | b;
            4'b0111:
                c = ~(a | b);
            4'b1000:
                c = a ^ b;
            4'b1001:
                c = a << b[4: 0];
            4'b1010:
                c = (ALUCtrl[0]) ? (signed(a) >>> b[4: 0]) : (a >> b[4: 0]);
            default: ;
        endcase
endmodule