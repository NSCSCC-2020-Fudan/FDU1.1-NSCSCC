# AXI3 接口
## 文件
* `src`：源代码目录
    * `AXI3Read.sv`、`AXI3ReadAddr.sv`、`AXI3Write.sv`、`AXI3WriteAddr.sv`、`AXI3WriteResp.sv`：AXI3 协议接口的 SystemVerilog `interface`。
    * `AXI3Wrap.sv`：将 SystemVerilog `interface` 拆解为龙芯提供的接口。
    * `include`：头文件（`.svh`）目录。
        * `common.svh`：定义了 `nibble_t`、`word_t`。
        * `enums.svh`：定义了一些在 AXI3 接口中用到的数据类型。
    * `workaround`：可以忽略。参见目录下的 `README.md`。

## TODO
* [ ] CPU 访存动作到 AXI3 协议的转换。