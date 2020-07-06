`include "mips.svh"

module Decode (
    Dreg.out in,
    Ereg.in out,
    rfi.decode rf
);
    
endmodule

module MainDec (
    input op_t op,
    output control_t ctl
);
    always_comb begin
        ctl = '0;
        case (op)
            `OP_RT: begin
                
            end
            default: begin
                pass
            end
        endcase
    end
endmodule

module ALUDec (
    input func_t func,
    input aluop_t aluop,
    output alufunc_t alufunc
);
    always_comb begin
        case (aluop)
            
        endcase
    end
endmodule