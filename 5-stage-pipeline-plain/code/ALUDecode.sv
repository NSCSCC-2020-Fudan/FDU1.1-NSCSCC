/*
0000: +
0001: -
0010: <
0011: /
0100: *
0101: &
0110: |
0111: ~|
1000: ^
1001: <<
1010: >>
1011: 
1111: __
0 sign; 1 unsign;
*/
module ALUDec(
        input logic [2: 0] Type,
        input logic [5: 0] Func,
        output logic [4: 0] ALUCtrl,
        output logic ALUMode
    );

    always @(*)
        case(Type) 
            3'b000:
                begin
                    case(Func)
                        6'b100000: ALUCtrl = 5'b0000_0;
                        6'b100001: ALUCtrl = 5'b0000_1;//+
                        6'b100010: ALUCtrl = 5'b0001_0;
                        6'b100011: ALUCtrl = 5'b0001_1;//-
                        6'b101010: ALUCtrl = 5'b0010_0;
                        6'b101011: ALUCtrl = 5'b0010_1;//<
                        6'b011010: ALUCtrl = 5'b0011_0;
                        6'b011011: ALUCtrl = 5'b0011_1;///
                        6'b011000: ALUCtrl = 5'b0100_0;
                        6'b011001: ALUCtrl = 5'b0100_1;//*
                        6'b100100: ALUCtrl = 5'b0101_0;//&
                        6'b100111: ALUCtrl = 5'b0110_0;//|
                        6'b100101: ALUCtrl = 5'b0111_0;//~|
                        6'b100110: ALUCtrl = 5'b1000_0;//^
                        6'b000100: ALUCtrl = 5'b1001_0;//<<
                        6'b000111: ALUCtrl = 5'b1010_0;//>>a
                        6'b000110: ALUCtrl = 5'b1010_1;//>>l
                        default: ALUCtrl = 5'b1111_0;
                    endcase
                end
                //R-Type
            3'b001:
                begin
                    case(Type)
                        6'b001000: ALUCtrl = 5'b0000_0;
                        6'b001001: ALUCtrl = 5'b0000_1;//+
                        6'b001010: ALUCtrl = 5'b0010_0;
                        6'b001011: ALUCtrl = 5'b0010_1;//<
                        6'b001100: ALUCtrl = 5'b0101_0;//&
                        6'b001111: ALUCtrl = 5'b0000_0;//LUI
                        6'b001101: ALUCtrl = 5'b0110_0;//|
                        6'b001110: ALUCtrl = 5'b1000_0;//^
                        default: ALUCtrl = 5'b1111_0;
                    endcase
                end
                //I-Type
            3'b010:
                ALUCtrl = 5'b0000_0;
                //Memory
            default:
                ALUCtrl = 5'b1111_0;
        endcase
    
endmodule
