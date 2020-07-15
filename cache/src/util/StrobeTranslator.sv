/**
 * translate to AXI strobe mask for 32bit data.
 */
module StrobeTranslator #(
    localparam type size_t   = logic [1:0],
    localparam type offset_t = logic [1:0],
    localparam type strobe_t = logic [3:0]
) (
    input  size_t   size,
    input  offset_t offset,
    output strobe_t strobe
);
    always_comb
    unique case ({size, offset})
        4'b00_00: strobe = 4'b0001;
        4'b00_01: strobe = 4'b0010;
        4'b00_10: strobe = 4'b0100;
        4'b00_11: strobe = 4'b1000;
        4'b01_00: strobe = 4'b0011;
        4'b01_10: strobe = 4'b1100;
        4'b10_00: strobe = 4'b1111;
        default:  strobe = 4'b0000;
    endcase
endmodule