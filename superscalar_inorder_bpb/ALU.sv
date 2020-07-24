`include "mips.svh"

module ALU (
        input word_t a, 
        input word_t b,
        input alufunc_t alufunc,
        output word_t c,
        output logic exception_of
    );
    shamt_t shamt;
    assign shamt = a[4: 0];
    logic [32:0] temp;

    always_comb begin
        exception_of = 0;
        temp = '0;
        
        case (alufunc)
            ALU_AND: begin
                c = a & b;
            end
            ALU_ADD: begin
                c = a + b;
                temp = {a[31], a} + {b[31], b};
                exception_of = (temp[32] != temp[31]);
            end
            ALU_OR: begin
                c = a | b;
            end
            ALU_SLL: begin
                c = b << shamt;
            end
            ALU_SRL: begin
                c = b >> shamt; 
            end
            ALU_SRA: begin
                c = signed'(b) >>> shamt;
            end
            ALU_SUB: begin
                c = a - b;
                temp = {a[31], a} - {b[31], b};
                exception_of = (temp[32] != temp[31]);
            end
            ALU_SLT: begin
                c = (signed'(a) < signed'(b)) ? 32'b1 : 32'b0; 
            end
            ALU_NOR: begin
                c = ~(a | b);
            end
            ALU_XOR: begin
                c = a ^ b;
            end
            ALU_ADDU: begin
                c = a + b;
            end
            ALU_SUBU: begin
                c = a - b;
            end
            ALU_SLTU: begin
                c = (a < b) ? 32'b1 : 32'b0;
            end
            ALU_PASSA: begin
                c = a;
            end
            ALU_LUI : begin
                c = {b[15:0], 16'b0};
            end
            ALU_PASSB: begin
                c = b;
            end
            default: begin
                c = '0;
            end
        endcase
    end
endmodule