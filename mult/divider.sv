// unsigned
`include "mips.svh"
`include "divider.svh"
module divider(
    input logic clk, reset,
    input logic valid,
    input word_t a, b, // a / b
    output dword_t out, // {hi, lo}
    output logic ok
);
    logic [4:0] shift_left;
    divide_data_t [17:1]div;
    divide_data_t [16:0]div_new;
    always_ff @(posedge clk) begin
        if (reset) begin
            div <= '0;
        end else begin
            div[17:1] <= div_new[16:0];
        end
    end
    // stage 1
    assign div_new[0].ok = valid;
    assign div_new[0].Q = '0;
    divide_initial divide_initial(.ina(a), .inb(b), .outpa(div_new[0].PA), .outb(div_new[0].B), .shiftnum(div_new[0].shiftnum));

    genvar i;
    generate
        for (i=1; i<=16; i++) begin
            divide_process divide_process(.in(div[i]), .out(div_new[i]));
        end
    endgenerate

    // output
    assign ok = div[17].ok;
    assign out = div[17].PA[64] ? 
                {{(div[17].PA[63:32] + div[17].B) >> div[17].shiftnum}, {div[17].Q - 32'b1} } // negetive
               :{{div[17].PA[63:32] >> div[17].shiftnum}, div[17].Q };
endmodule


module divide_process (
    input divide_data_t in,
    output divide_data_t out
);
    // quotient_bit_t [7:0]q;
    // genvar i;
    // generate
    //     for (i=0; i<8; ++i) begin
    //         divide_table divide_table(.b(in.B[30:28]), .pa(in.PA[64:59]), .q(q[i]));
    //     end
    // endgenerate
    quotient_bit_t q;
    divide_table divide_table(.b(in.B[30:28]), .pa(in.PA[64:59]), .q(q));
    always_comb begin
        case (q)
            TWO_P: begin
                out.Q = {in.Q[29:0], 2'b10};
                out.PA[64:32] = in.PA[62:30] - {in.B[31:0], 1'b0};
            end
            ONE_P: begin
                out.Q = {in.Q[29:0], 2'b01};
                out.PA[64:32] = in.PA[62:30] - {1'b0, in.B[31:0]};
            end
            ZERO_P: begin
                out.Q = {in.Q[29:0], 2'b00};
                out.PA[64:32] = in.PA[62:30];
            end
            ONE_N: begin
                out.Q = {{in.Q[29:0] - 30'b01}, 2'b11};
                out.PA[64:32] = in.PA[62:30] + {1'b0, in.B[31:0]};
            end
            TWO_N: begin
                out.Q = {{in.Q[29:0] - 30'b01}, 2'b10};
                out.PA[64:32] = in.PA[62:30] + {in.B[31:0], 1'b0};
            end
            default: begin
                out.PA[64:32] = '0;
                out.Q = '0;
            end
        endcase
    end
    assign out.ok = in.ok;
    assign out.shiftnum = in.shiftnum;
    assign out.B = in.B;
    // assign out.PA[31:0] = in.PA[31:0];
    assign out.PA[31:0] = {in.PA[29:0], 2'b00};
endmodule

module divide_table (
    input logic [2:0] b, // b[30:28]
    input logic [5:0] pa,
    output quotient_bit_t q
);
    always_comb begin
        case (b)
            3'b000:begin
                case (pa)
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = TWO_N;
                    6'b110111: q = TWO_N;
                    6'b111000: q = TWO_N;
                    6'b111001: q = TWO_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ONE_N;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ONE_P;
                    6'b000011: q = ONE_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = TWO_P;
                    6'b000111: q = TWO_P;
                    6'b001000: q = TWO_P;
                    6'b001001: q = TWO_P;
                    6'b001010: q = TWO_P;
                    6'b001011: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b001:begin
                case (pa)
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = TWO_N;
                    6'b110111: q = TWO_N;
                    6'b111000: q = TWO_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ONE_N;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ONE_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = TWO_P;
                    6'b001000: q = TWO_P;
                    6'b001001: q = TWO_P;
                    6'b001010: q = TWO_P;
                    6'b001011: q = TWO_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b010:begin
                case (pa)
                    6'b110001: q = TWO_N;
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = TWO_N;
                    6'b110111: q = TWO_N;
                    6'b111000: q = ONE_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ONE_N;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ONE_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = ONE_P;
                    6'b001000: q = TWO_P;
                    6'b001001: q = TWO_P;
                    6'b001010: q = TWO_P;
                    6'b001011: q = TWO_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    6'b001110: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b011:begin
                case (pa)
                    6'b110000: q = TWO_N;
                    6'b110001: q = TWO_N;
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = TWO_N;
                    6'b110111: q = TWO_N;
                    6'b111000: q = ONE_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ONE_N;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ONE_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = ONE_P;
                    6'b001000: q = ONE_P;
                    6'b001001: q = TWO_P;
                    6'b001010: q = TWO_P;
                    6'b001011: q = TWO_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    6'b001110: q = TWO_P;
                    6'b001111: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b100:begin
                case (pa)
                    6'b101110: q = TWO_N;
                    6'b101111: q = TWO_N;
                    6'b110000: q = TWO_N;
                    6'b110001: q = TWO_N;
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = TWO_N;
                    6'b110111: q = ONE_N;
                    6'b111000: q = ONE_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ZERO_P;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ZERO_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = ONE_P;
                    6'b001000: q = ONE_P;
                    6'b001001: q = ONE_P;
                    6'b001010: q = TWO_P;
                    6'b001011: q = TWO_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    6'b001110: q = TWO_P;
                    6'b001111: q = TWO_P;
                    6'b010000: q = TWO_P;
                    6'b010001: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b101:begin
                case (pa)
                    6'b101101: q = TWO_N;
                    6'b101110: q = TWO_N;
                    6'b101111: q = TWO_N;
                    6'b110000: q = TWO_N;
                    6'b110001: q = TWO_N;
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = ONE_N;
                    6'b110111: q = ONE_N;
                    6'b111000: q = ONE_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ZERO_P;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ZERO_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = ONE_P;
                    6'b001000: q = ONE_P;
                    6'b001001: q = ONE_P;
                    6'b001010: q = TWO_P;
                    6'b001011: q = TWO_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    6'b001110: q = TWO_P;
                    6'b001111: q = TWO_P;
                    6'b010000: q = TWO_P;
                    6'b010001: q = TWO_P;
                    6'b010010: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b110:begin
                case (pa)
                    6'b101100: q = TWO_N;
                    6'b101101: q = TWO_N;
                    6'b101110: q = TWO_N;
                    6'b101111: q = TWO_N;
                    6'b110000: q = TWO_N;
                    6'b110001: q = TWO_N;
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = TWO_N;
                    6'b110110: q = ONE_N;
                    6'b110111: q = ONE_N;
                    6'b111000: q = ONE_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ZERO_P;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ZERO_P;
                    6'b000100: q = ONE_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = ONE_P;
                    6'b001000: q = ONE_P;
                    6'b001001: q = ONE_P;
                    6'b001010: q = ONE_P;
                    6'b001011: q = TWO_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    6'b001110: q = TWO_P;
                    6'b001111: q = TWO_P;
                    6'b010000: q = TWO_P;
                    6'b010001: q = TWO_P;
                    6'b010010: q = TWO_P;
                    6'b010011: q = TWO_P;
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            3'b111:begin
                case (pa)
                    6'b101010: q = TWO_N;
                    6'b101011: q = TWO_N;
                    6'b101100: q = TWO_N;
                    6'b101101: q = TWO_N;
                    6'b101110: q = TWO_N;
                    6'b101111: q = TWO_N;
                    6'b110000: q = TWO_N;
                    6'b110001: q = TWO_N;
                    6'b110010: q = TWO_N;
                    6'b110011: q = TWO_N;
                    6'b110100: q = TWO_N;
                    6'b110101: q = ONE_N;
                    6'b110110: q = ONE_N;
                    6'b110111: q = ONE_N;
                    6'b111000: q = ONE_N;
                    6'b111001: q = ONE_N;
                    6'b111010: q = ONE_N;
                    6'b111011: q = ONE_N;
                    6'b111100: q = ONE_N;
                    6'b111101: q = ZERO_P;
                    6'b111110: q = ZERO_P;
                    6'b111111: q = ZERO_P;
                    6'b000000: q = ZERO_P;
                    6'b000001: q = ZERO_P;
                    6'b000010: q = ZERO_P;
                    6'b000011: q = ZERO_P;
                    6'b000100: q = ZERO_P;
                    6'b000101: q = ONE_P;
                    6'b000110: q = ONE_P;
                    6'b000111: q = ONE_P;
                    6'b001000: q = ONE_P;
                    6'b001001: q = ONE_P;
                    6'b001010: q = ONE_P;
                    6'b001011: q = ONE_P;
                    6'b001100: q = TWO_P;
                    6'b001101: q = TWO_P;
                    6'b001110: q = TWO_P;
                    6'b001111: q = TWO_P;
                    6'b010000: q = TWO_P;
                    6'b010001: q = TWO_P;
                    6'b010010: q = TWO_P;
                    6'b010011: q = TWO_P;
                    6'b010100: q = TWO_P;
                    6'b010101: q = TWO_P; 
                    default: begin
                        q = WRONG_N;
                    end
                endcase
            end
            default: begin
                q = WRONG_N;
            end
        endcase
    end
endmodule

module divide_initial (
    input word_t ina,
    input word_t inb,
    output logic [64:0] outpa,
    output word_t outb,
    output logic[4:0] shiftnum
);
    logic [64:0] inpa;
    assign inpa = {33'b0, ina};
    always_comb begin
        priority case (1'b1)
            inb[31] : {outpa, outb, shiftnum} = {inpa[64:0], inb[31:0], 5'd0};
            inb[30] : {outpa, outb, shiftnum} = {{inpa[63:0], 1'b0}, {inb[30:0], 1'b0}, 5'd1};
            inb[29] : {outpa, outb, shiftnum} = {{inpa[62:0], 2'b0}, {inb[29:0], 2'b0}, 5'd2};
            inb[28] : {outpa, outb, shiftnum} = {{inpa[61:0], 3'b0}, {inb[28:0], 3'b0}, 5'd3};
            inb[27] : {outpa, outb, shiftnum} = {{inpa[60:0], 4'b0}, {inb[27:0], 4'b0}, 5'd4};
            inb[26] : {outpa, outb, shiftnum} = {{inpa[59:0], 5'b0}, {inb[26:0], 5'b0}, 5'd5};
            inb[25] : {outpa, outb, shiftnum} = {{inpa[58:0], 6'b0}, {inb[25:0], 6'b0}, 5'd6};
            inb[24] : {outpa, outb, shiftnum} = {{inpa[57:0], 7'b0}, {inb[24:0], 7'b0}, 5'd7};
            inb[23] : {outpa, outb, shiftnum} = {{inpa[56:0], 8'b0}, {inb[23:0], 8'b0}, 5'd8};
            inb[22] : {outpa, outb, shiftnum} = {{inpa[55:0], 9'b0}, {inb[22:0], 9'b0}, 5'd9};
            inb[21] : {outpa, outb, shiftnum} = {{inpa[54:0], 10'b0}, {inb[21:0], 10'b0}, 5'd10};
            inb[20] : {outpa, outb, shiftnum} = {{inpa[53:0], 11'b0}, {inb[20:0], 11'b0}, 5'd11};
            inb[19] : {outpa, outb, shiftnum} = {{inpa[52:0], 12'b0}, {inb[19:0], 12'b0}, 5'd12};
            inb[18] : {outpa, outb, shiftnum} = {{inpa[51:0], 13'b0}, {inb[18:0], 13'b0}, 5'd13};
            inb[17] : {outpa, outb, shiftnum} = {{inpa[50:0], 14'b0}, {inb[17:0], 14'b0}, 5'd14};
            inb[16] : {outpa, outb, shiftnum} = {{inpa[49:0], 15'b0}, {inb[16:0], 15'b0}, 5'd15};
            inb[15] : {outpa, outb, shiftnum} = {{inpa[48:0], 16'b0}, {inb[15:0], 16'b0}, 5'd16};
            inb[14] : {outpa, outb, shiftnum} = {{inpa[47:0], 17'b0}, {inb[14:0], 17'b0}, 5'd17};
            inb[13] : {outpa, outb, shiftnum} = {{inpa[46:0], 18'b0}, {inb[13:0], 18'b0}, 5'd18};
            inb[12] : {outpa, outb, shiftnum} = {{inpa[45:0], 19'b0}, {inb[12:0], 19'b0}, 5'd19};
            inb[11] : {outpa, outb, shiftnum} = {{inpa[44:0], 20'b0}, {inb[11:0], 20'b0}, 5'd20};
            inb[10] : {outpa, outb, shiftnum} = {{inpa[43:0], 21'b0}, {inb[10:0], 21'b0}, 5'd21};
            inb[9] : {outpa, outb, shiftnum} = {{inpa[42:0], 22'b0}, {inb[9:0], 22'b0}, 5'd22};
            inb[8] : {outpa, outb, shiftnum} = {{inpa[41:0], 23'b0}, {inb[8:0], 23'b0}, 5'd23};
            inb[7] : {outpa, outb, shiftnum} = {{inpa[40:0], 24'b0}, {inb[7:0], 24'b0}, 5'd24};
            inb[6] : {outpa, outb, shiftnum} = {{inpa[39:0], 25'b0}, {inb[6:0], 25'b0}, 5'd25};
            inb[5] : {outpa, outb, shiftnum} = {{inpa[38:0], 26'b0}, {inb[5:0], 26'b0}, 5'd26};
            inb[4] : {outpa, outb, shiftnum} = {{inpa[37:0], 27'b0}, {inb[4:0], 27'b0}, 5'd27};
            inb[3] : {outpa, outb, shiftnum} = {{inpa[36:0], 28'b0}, {inb[3:0], 28'b0}, 5'd28};
            inb[2] : {outpa, outb, shiftnum} = {{inpa[35:0], 29'b0}, {inb[2:0], 29'b0}, 5'd29};
            inb[1] : {outpa, outb, shiftnum} = {{inpa[34:0], 30'b0}, {inb[1:0], 30'b0}, 5'd30};
            inb[0] : {outpa, outb, shiftnum} = {{inpa[33:0], 31'b0}, {inb[0:0], 31'b0}, 5'd31};


            default: begin
                {outpa, outb, shiftnum} = '0;
            end
        endcase
    end
endmodule