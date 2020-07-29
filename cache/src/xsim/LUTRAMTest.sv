`ifndef VERILATOR

module LUTRAMTest();
    logic clk = 0;
    always #5 clk = ~clk;

    logic [3:0] write_en = 0;
    logic [31:0] addr = 0;
    logic [31:0] data_in = 0;
    logic [31:0] data_out;

    LUTRAM #(.DATA_WIDTH(33), .ENABLE_BYTE_WRITE(0)) inst33(.*);
    LUTRAM inst(.*);

    initial begin
    #8
        write_en = 4'b1111;
        data_in = 32'h12345678;
    #10
        addr = 1;
        data_in = 32'h87654321;
    #10
        addr = 2;
        data_in = 32'hdeadbeef;
    #10
        addr = 3;
        write_en = 4'b1010;
        data_in = 32'hcccccccc;
    #10
        write_en = 0;
    #2
        addr = 0;
        data_in = 32'habcdef99;
    #3
        addr = 1;
    #3
        write_en = 4'b1111;
        addr = 2;
    #2
        addr = 3;
    #40 $finish;
    end
endmodule

`endif