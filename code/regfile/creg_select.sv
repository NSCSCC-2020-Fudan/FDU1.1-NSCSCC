`include "interface.svh"
module creg_select 
    import common::*;(
    payloadRAM_intf.creg_select self
);
    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            unique case (1'b1)
                self.creg1[i][5] : self.cdata1[i] = self.cp01[i];
                self.creg1[i][6] : self.cdata1[i] = self.creg1[i][0] ? self.hi : self.lo;
                default: begin
                    self.cdata1[i] = self.arf1[i];
                end
            endcase
        end
        
    end
    always_comb begin
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            unique case (1'b1)
                self.creg2[i][5] : self.cdata2[i] = self.cp02[i];
                self.creg2[i][6] : self.cdata2[i] = self.creg2[i][0] ? self.hi : self.lo;
                default: begin
                    self.cdata2[i] = self.arf2[i];
                end
            endcase
        end
        
    end
endmodule