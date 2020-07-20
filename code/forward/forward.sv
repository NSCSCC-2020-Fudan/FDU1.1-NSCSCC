module forward 
    import common::*;
    import forward_pkg::*;
    import execute_pkg::*;(
    
);
    forward_t [FU_NUM-1:0] forwards;
    entry_t [FU_NUM-1:0] entrys;
    always_comb begin
        for (int i=0; i<FU_NUM; i++) begin
            forwards[i] = '0;
            for (int j=ALU_NUM-1; j>=0; j--) begin
                if (dst[j] != 0 && dst[j] == entrys[i].src1.id) begin
                    forwards[i].valid1 = 1'b1;
                    forwards[i].fw1 = j;
                end
                if (dst[j] != 0 && dst[j] == entrys[i].src2.id) begin
                    forwards[i].valid2 = 1'b1;
                    forwards[i].fw2 = j;
                end
            end
        end
    end
endmodule