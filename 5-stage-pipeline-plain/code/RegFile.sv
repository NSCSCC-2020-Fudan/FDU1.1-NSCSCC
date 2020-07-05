`include "MIPS.svh"
module RegFile(
        input logic clk, reset,
        input logic [4: 0] R1, R2,
        output logic [31: 0] R1Read, R2Read,

        input logic WriteEn,
        input logic [4: 0] WriteReg,
        input logic [31: 0] WriteData,

        input logic HIWriteEn, LOWriteEn,
        input logic [31: 0] HIWriteData, LOWriteData,
        output logic [31: 0] HIRead, LORead
    );

    integer i;
    logic [31: 0] HI, LO;
    logic [31: 0] Register [31: 0];
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    HI = 32'b0;
                    LO = 32'b0;
                    for (i = 0; i < 32; i = i + 1)
                        Register[i] = 32'b0;
                end
            else 
                begin
                    if (WriteEn) 
                        Register[WriteReg] = WriteData;
                    if (HIWriteEn)
                        HI = HIWriteData;
                    if (LOWriteEN)
                        LO = LOWriteData;
                end
        end

endmodule