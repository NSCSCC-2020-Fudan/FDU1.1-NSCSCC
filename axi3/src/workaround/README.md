# Workaround

在 Vivado 中，该文件夹中的源码可以忽略。

## `*Top.sv`

在使用 Verilator 检查单个 module 的语法错误时，由于 Verilator 不支持顶层模块的接口中有 `interface`，因此需要一个额外的顶层模块，驱动每个 `interface`，避免 Verilator 在 `interface` 上报错，从而缓解这一问题。

```verilog
`ifdef VERILATOR
// verilator lint_off PINMISSING
// verilator lint_off MODDUP

module SomethingTop();
    // 驱动代码
endmodule

`endif
```