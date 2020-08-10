`include "mips.svh"

module regfile (
        input logic clk, reset,
        input rf_w_t [1: 0] rfw,
        input creg_addr_t [3: 0] reg_addrW,
        output word_t [3: 0] reg_dataW,
        input creg_addr_t [4: 0] reg_addrC,
        output word_t [4: 0] reg_dataC 
    );
    word_t [31:0] R;
    always_ff @(posedge clk) begin
        if (~reset)
            R <= '0;
        else 
            begin
                if (rfw[1].wen && (rfw[1].addr != '0)) 
                    R[rfw[1].addr] = rfw[1].wd;
                else
                    R[0] = '0;
                    
                if (rfw[0].wen && (rfw[0].addr != '0)) 
                    R[rfw[0].addr] = rfw[0].wd;
                else
                    R[0] = '0;
            end
    end
    
    assign reg_dataW[3] = (reg_addrW[3] != '0) ? R[reg_addrW[3]] : '0;
    assign reg_dataW[2] = (reg_addrW[2] != '0) ? R[reg_addrW[2]] : '0;
    assign reg_dataW[1] = (reg_addrW[1] != '0) ? R[reg_addrW[1]] : '0;
    assign reg_dataW[0] = (reg_addrW[0] != '0) ? R[reg_addrW[0]] : '0;
    
    assign reg_dataC[4] = (reg_addrC[4] != '0) ? R[reg_addrC[4]] : '0;
    assign reg_dataC[3] = (reg_addrC[3] != '0) ? R[reg_addrC[3]] : '0;
    assign reg_dataC[2] = (reg_addrC[2] != '0) ? R[reg_addrC[2]] : '0;
    assign reg_dataC[1] = (reg_addrC[1] != '0) ? R[reg_addrC[1]] : '0;
    assign reg_dataC[0] = (reg_addrC[0] != '0) ? R[reg_addrC[0]] : '0;

endmodule