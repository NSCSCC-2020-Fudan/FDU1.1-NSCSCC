// unsigned
`include "mips.svh"
module divider(
    input logic clk, reset,
    input logic valid,
    input word_t a, b, // a / b
    output dword_t out, // {lo, hi}
    output logic ok
);
    logic [4:0] shift_left;
    divide_data_t div1, div2, div3, div4;
    divide_data_t div1_new, div2_new, div3_new, div4_new;
    always_ff @(posedge clk) begin
        if (reset) begin
            {div2, div3, div4} <= '0;
        end else begin
            {div2, div3, div4} <= {div1_new, div2_new, div3_new};
        end
    end
    // stage 1
    assign div1_new.ok = valid;
    bitcount bitcount(.ina(a), .inb(b), .outpa(div1_new.PA), .outb(div1_new.B));
    assign div1_new.R =



    // end
endmodule


module divide_process (
    input divide_data_t in,
    output divide_data_t out
);
    
endmodule

module divinitial (
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
            inb[31] : {outpa, outb, shiftnum} = {{inpa[64:0], 0'b0}, {inb[31:0], 0'b0}, 5'd0};
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
                {outpa, outb, shiftmum} = '0;
            end
        endcase
    end
endmodule