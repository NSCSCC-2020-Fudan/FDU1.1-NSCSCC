module alu (
    input word_t a, b,
    input alufunc_t alufunc,
    output word_t c
);
    logic[5:0] shamt;
    assign shamt = b[5:0];
    always_comb begin
        case (alufunc)
            AND: begin
                c = a & b;
            end
            ADD: begin
                c = a + b;
            end
            OR: begin
                c = a | b;
            end
            SLL: begin
                c = a << shamt;
            end
            SRL: begin
                c = a >> shamt; 
            end
            SRA: begin
                c = a >>> shamt;
            end
            SUB: begin
                c = a - b;
            end
            SLT: begin
                c = ((signed)a < (signed)b) ? 32'b1 : 32'b0; 
            end
            NOR: begin
                c = ~(a ^ b);
            end
            XOR: begin
                c = a ^ b;
            end
            ADDU: begin
                c = a + b;
            end
            SUBU: begin
                c = a - b;
            end
            SLTU: begin
                c = (a < b) ? 32'b1 : 32'b0;
            end
            default: begin
                c = '0;
            end
        endcase
    end
endmodule