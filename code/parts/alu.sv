module alu (
    input word_t a, b,
    input alufunc_t alufunc,
    output word_t c,
    output logic exception_of
);
    shamt_t shamt;
    assign shamt = b[5:0];
    logic [32:0]temp;
    always_comb begin
        exception_of = 0;
        temp = '0;
        case (alufunc)
            AND: begin
                c = a & b;
            end
            ADD: begin
                c = a + b;
                temp = {a[31], a} + {b[31], b};
                exception_of = (temp[32] != temp[31]);
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
                temp = {a[31], a} - {b[31], b};
                exception_of = (temp[32] != temp[31]);
            end
            SLT: begin
                c = (signed'(a) < signed'(b)) ? 32'b1 : 32'b0; 
            end
            NOR: begin
                c = ~(a & b);
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