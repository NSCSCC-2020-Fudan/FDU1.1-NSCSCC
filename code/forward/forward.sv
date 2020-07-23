module forward 
    import common::*;
    import forward_pkg::*;
    import execute_pkg::*;(
    
);
    forward_t [FU_NUM-1:0] forwards; // to execute
    preg_addr_t [ALU_NUM-1:0] src1, src2; // from execute
    preg_addr_t [ALU_NUM-1:0] dst; // from commit
    always_comb begin
        for (int i=0; i<FU_NUM; i++) begin
            forwards[i] = '0;
            for (int j=ALU_NUM-1; j>=0; j--) begin
                if (dst[j] != 0 && dst[j] == src1[i]) begin
                    forwards[i].valid1 = 1'b1;
                    forwards[i].fw1 = j;
                end
                if (dst[j] != 0 && dst[j] == src2[i]) begin
                    forwards[i].valid2 = 1'b1;
                    forwards[i].fw2 = j;
                end
            end
        end
    end
endmodule