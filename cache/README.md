# Cache

<img src="assets/architecture.png" width="100%" />

## 文件结构

* `assets/`：非源码的资源文件。
* `build/`：构建测试时的临时文件夹。
* `src/`：源代码。
    * `include/`：SystemVerilog 头文件。
    * `ram/`：RAM 相关的基础模块。
    * `util/`：辅助模块、总线转接模块。
    * `xsim/`：Vivado 下的测试源码。
* `test/`：测试代码。
* `trace/`：保存波形图的文件夹。默认不上传波形图文件（`.fst` 和 `.vcd`），只上传 GTKWave 的配置文件（`.gtkw`）。
* `.gitignore`
* `Makefile`：使用 `make run` 运行测试。
* `README.md`：本文件。
* `wrap.py`：顶层模块生成器。用于测试。

## 模块测试

部分需要与 IP 核交互的模块是在 Vivado 上测试的，测试代码在 `src/xsim` 中。另外一些代码会先使用 Verilator 进行仿真测试。运行这些仿真测试只需要使用以下命令：

```shell
make run top=[顶层模块名称]
```

这里要求 `$(top).sv` 在 `src/` 目录下，并且编写了对应的 `$(top).cpp` 测试源码，放置于 `test/` 目录下。

编译宏：

* `RUN_ALL`：是否不跳过被 `SKIP` 标记的测试。
* `FAST_SIMULATION`：编译时开启 O2 优化，并且取消 `-fsanitize=undefined`。

在跑正式测试时建议使用 `RUN_ALL=1 FAST_SIMULATION=1`。

## 命名逻辑

所有 master → slave 的请求以 `req` 进行标注，而 slave → master 的反馈以 `resp` 进行标注。例如，`axi_req_t` 和 `axi_resp_t`。

## Cache 总线（`cbus`/$bus）

Cache 总线用于 cache 读取/写回一整条 cache line。在时钟上升沿时进行握手。该总线不是双向握手，cache（master）一方必须进行忙等待，slave 一方的 `okay` 和 `last` 信号只持续一拍。

方向 “`→`” 表示 master 到 slave 的信号，“`←`” 表示 slave 到 master 的信号。

参数：

* `DATA_WIDTH`：读/写的数据宽度（`CBUS_DATA_WIDTH`）。
* `LEN_BITS`：最大读/写长度减一所需的位数（`CBUS_LEN_BITS`）。

信号：

* `valid`：`→`。是否发出请求。
* `is_write`：`→`。本次请求是否是写请求。
* `addr[31:0]`：`→`。读/写的初始地址。
* `order[LEN_BITS - 1:0]`：`→`。阶数。用于计算连续读/写的次数。要求 cache line 的大小必须是 2 的幂次，因此次数为 2<sup>order</sup>。
    * 中阶任务中的 AXI 总线单次 burst 传输只能传 16 个。因此转接时可能需要多次传输。
* `wdata[DATA_WIDTH - 1:0]`：`→`。单次写入的数据。
* `rdata[DATA_WIDTH - 1:0]`：`←`。单次读出的数据。
* `okay`：`←`。单次读取/写入是否成功。
* `last`：`←`。本次数据传输是否完成。

Master 需要读写时，只用准备好 `is_write`、`addr` 和 `order`，然后全程拉起 `valid` 信号。之后等待 slave 反馈 `okay` 信息。每次收到 `okay` 时，如果是读取，则 `rdata` 是读取到的数据；如果是写入，则 `wdata` 应换上下一个要写入的数据。读/写都是顺序读写。当 slave 返回 `last` 时，表明操作已经完成，此时可以撤去 `valid` 信号。该总线要求在 `valid` 等于 1 的时候，`is_write`、`addr` 和 `order` 不能改变；在 slave 反馈 `last` 前，`valid` 不能撤下。

## 类 SRAM 总线（`sramx`/`SRAMx`/SRAM*）

参考 “`A12_类SRAM接口说明.pdf`” 中的规定。