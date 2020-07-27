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
    * `ip/`：Vivado 中用到 IP 核的配置文件（`.xci`）。
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

可以使用 `make all` 来运行所有在 `test/` 目录下的测试。

## 命名逻辑

所有 master → slave 的请求以 `req` 进行标注，而 slave → master 的反馈以 `resp` 进行标注。例如，`axi_req_t` 和 `axi_resp_t`。

对于总线的转接模块 `XBusToYBus`，`XBus` 表示从 master 一端过来的总线类型，`YBus` 表示 slave 一端的总线类型。例如，`SRAMxToInstrBus` 表示把 CPU 出来的 SRAM* 总线转为 IBus 总线。

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

$bus 并没有规定 AXI burst 传输的类型，也没有规定 `addr` 是否需要和 cache line 的大小对齐。可以根据需要选择 `INCR` 类型或者 `WRAP` 类型。

## 类 SRAM 总线（`sramx`/`SRAMx`/SRAM*）

参考 “`A12_类SRAM接口说明.pdf`” 中的规定。

关于握手信号的规定：

* Slave 可以无视 master 的 `req` 信号而拉起 `addr_ok`，表示 slave 当前随时可以接收新的请求。
* Slave 需要保证只在必要的时候拉起 `data_ok`，表示之前收到的请求处理完成。当 slave 当前没有处理任何请求时，不能拉起 `data_ok`，即便 master 的 `req` 信号没有拉起。
* 对于同一个周期的请求，`addr_ok` 和 `data_ok` 可以同时为 1，表示数据可以在当前周期准备好（读取）或者是在下一个时钟上升沿更新（写入）。
* 如果 slave 支持同时接收多个请求，则按照文档中关于处理连续读写的要求来。

## 取指总线（`ibus`/IBus）

NOTE：不是指输入法框架（Fcitx 大法好

IBus 对 SRAM* 总线接口做了简化。取指只需要发出请求信号 `req` 和地址 `addr`。原则上在 cache 未返回 `addr_ok` 的时候不能撤下 `req`。但部分情况下提前撤下可能不会有问题。

参数：

* `IBUS_DATA_WIDTH`：IBus 一次取指的宽度。如果是双发射，则为 64。以此类推，4 发射就是 128。
* `IBUS_WORD_WIDTH`：指令的宽度。一般固定为 32。

信号：

* `req`：表示是否有读取请求。
* `addr`：请求的地址（PC）。要求和指令宽度对齐。
* `addr_ok`：表示地址是否被 cache 接收（例如通过了 cache 的第一级流水线阶段）。`addr_ok` 握手成功后可以撤下 `req` 信号。
* `data_ok`：表示数据是否准备好。
* `data`：抓取到的数据。与 `index` 之间需要配合使用。
* `index`：`data` 相当于是一个指令的数组，而 `index` 指示这个数组中第一条有效的数据（指令）的下标。例如，如果 `index` 为 0，则表示 `data` 中的所有指令都是有效的。如果是双发射，而且 `index` 为 1，则表示此时只有第二条指令是有效的。

在目录 `cache/util/` 下我们提供了一个 IBus 总线转接 SRAM* 总线的转接模块 `InstrBusToSRAMx`，用于在没有接入真正的 cache 时，测试与 IBus 的交互。

## `mycpu_top`

Cache 部分只会修改 CPU 顶层模块的代码。代码位于 `code/mycpu_top.sv`。

参数：

* `USE_CACHE`：是否使用 cache layer。如果为 0 则 CPU 需要自己做地址翻译。
* `USE_ICACHE`：是否使用 ICache。如果为 0 则使用 `OneLineBuffer`。
* `USE_IBUS`：是否使用 IBus 。如果为 0 则会在 ICache 前接一个 `SRAMxToInstrBus` 的转接模块。