module ALUDec(
        input logic [2: 0] Type,
        input logic [5: 0] Func,
        output logic [3: 0] ALUCtrl,
        output logic ALUMode
    );

    logic [4: 0] ALUSig;
    assign ALUSig = {ALUCtrl, ALUMode};

    always @(*)
        case(Type) 
            3'b000:
                begin
                    case(Func)
                        6'b100000: ALUSig = 5'b0000_0;
                        6'b100001: ALUSig = 5'b0000_1;//+
                        6'b100010: ALUSig = 5'b0001_0;
                        6'b100011: ALUSig = 5'b0001_1;//-
                        6'b101010: ALUSig = 5'b0010_0;
                        6'b101011: ALUSig = 5'b0010_1;//<
                        6'b011010: ALUSig = 5'b0011_0;
                        6'b011011: ALUSig = 5'b0011_1;//*
                        6'b011000: ALUSig = 5'b0100_0;
                        6'b011001: ALUSig = 5'b0100_1;///
                        6'b100100: ALUSig = 5'b0101_0;//&
                        6'b100111: ALUSig = 5'b0110_0;//|
                        6'b100101: ALUSig = 5'b0111_0;//~|
                        6'b100110: ALUSig = 5'b1000_0;//^
                        6'b000100: ALUSig = 5'b1001_0;//<<
                        6'b000111: ALUSig = 5'b1010_0;//>>a
                        6'b000110: ALUSig = 5'b1010_1;//>>l
                        default: ALUSig = 5'b1111_0;
                    endcase
                end
                //R-Type
            3'b001:
                begin
                    case(Type)
                        6'b001000: ALUSig = 5'b0000_0;
                        6'b001001: ALUSig = 5'b0000_1;//+
                        6'b001010: ALUSig = 5'b0010_0;
                        6'b001011: ALUSig = 5'b0010_1;//<
                        6'b001100: ALUSig = 5'b0101_0;//&
                        6'b001111: ALUSig = 5'b1111_0;//
                        6'b001101: ALUSig = 5'b0110_0;//|
                        6'b001110: ALUSig = 5'b1000_0;//^
                        default: ALUSig = 5'b1111_0;
                    endcase
                end
                //I-Type
            3'b010:
                ALUSig = 5'b0000_0;
            default:
                AlUSig = 5'b1111_0;
        endcase
    
endmodule
/*
0000: +
0001: -
0010: <
0011: *
0100: /
0101: &
0110: |
0111: ~|
1000: ^
1001: <<
1010: >>
1011: 
1111: __
*/