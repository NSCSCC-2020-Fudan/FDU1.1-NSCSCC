`ifndef VERILATOR

module SimpleDualPortBRAMTest();
    logic clk = 0;
    always #5 clk = ~clk;

    logic reset, en;
    logic [3:0] write_en;
    logic [31:0] raddr, waddr, wdata;
    logic [31:0] rdata;
    SimpleDualPortBRAM inst(.*);

    initial begin
        en = 1;
        reset = 1;
        write_en = 0;
        raddr = 0;
        waddr = 0;
        wdata = 0;
    #200
        reset = 0;
    #17
        waddr = 0;
        wdata = 32'h12345678;
        write_en = 4'b1111;
    #20
        waddr = 1;
        wdata = 32'h87654321;
        write_en = 4'b1100;
    #20
        raddr = 1;
    #20
        write_en = 0;
    #40 $finish;
    end
endmodule

`endif