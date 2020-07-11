`ifdef VERILATOR
// verilator lint_off PINMISSING
// verilator lint_off MODDUP

module AXI3WrapTop(input clk, resetn);
    AXI3WriteAddr aw(clk, resetn);
    AXI3Write w(clk, resetn);
    AXI3WriteResp b(clk, resetn);
    AXI3ReadAddr ar(clk, resetn);
    AXI3Read r(clk, resetn);
    AXI3Wrap dut(
        .aw(aw.Slave),
        .w(w.Slave),
        .b(b.Slave),
        .ar(ar.Slave),
        .r(r.Slave)
    );
endmodule

`endif