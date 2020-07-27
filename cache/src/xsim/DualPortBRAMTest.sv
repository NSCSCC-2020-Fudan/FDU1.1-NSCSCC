`ifndef VERILATOR

module DualPortBRAMTest();
    logic clk = 0;
    always
        #5 clk = ~clk;

    logic reset, resetn, en;
    logic [3:0] write_en_1, write_en_2;
    logic [9:0] addr_1, addr_2;
    logic [31:0] data_in_1, data_in_2, data_out_1, data_out_2;
    assign resetn = ~reset;

    DualPortBRAM #(
        .RESET_VALUE("23333333"),
        .WRITE_MODE("read_first")
    ) inst(.*);

    initial begin
        en = 1;
        reset = 1;
        {write_en_1, write_en_2, addr_1, addr_2} = 0;
        {data_in_1, data_in_2} = 0;
    #200
        reset = 0;
    #10
        write_en_1 = 4'b1111;
        addr_1 = 0;
        data_in_1 = 32'h12345678;
    #20
        addr_1 = 1;
        data_in_1 = 32'h87654321;
    #10
        addr_1 = 4;
        data_in_1 = 32'haaaaaaaa;
        addr_2 = 2;
        data_in_2 = 32'hcccccccc;
        write_en_2 = 4'b0011;
    #10
        write_en_1 = 0;
        write_en_2 = 0;
        addr_2 = 0;
    #10
        addr_2 = 1;
    #10
        addr_2 = 2;
    #10
        addr_2 = 3;
    #10
        addr_2 = 4;
    #10
        en = 0;
    #10
        reset = 1;
    #200
        reset = 0;
    #10
        en = 1;
    #10
        addr_1 = 1;
        addr_2 = 2;
    #10
        reset = 1;
    #200
        reset = 0;
    #20
        addr_1 = 0;
        addr_2 = 4;
    #10
        en = 0;
        write_en_2 = 4'b1111;
        addr_2 = 3;
        data_in_2 = 32'h12121212;
    #10
        en = 1;
    #10
        write_en_2 = 0;
        en = 0;
    #10
        addr_2 = 0;
    #10
        en = 1;
    #20 $finish;
    end
endmodule

`endif