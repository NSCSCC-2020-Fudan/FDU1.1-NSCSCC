# 一个朴素的顺序双发射MIPS处理器

本项目为复旦大学FDU1.1队在第四届“龙芯杯”的参赛作品。



我们的成绩如下：

|          | 频率（MHZ） | 性能分 | IPC分 |
| -------- | ----------- | ------ | ----- |
| 初赛提交 | 110         | 74     |       |
| 决赛提交 | 95          |        | 34    |

`master`分支为我们的初赛提交。我们决赛提交的CPU在流水线架构上相对初赛提交几乎没有改进，且存在一些bug而无法启动Linux。虽然比赛已经结束，但我们不想留下遗憾，仍在其他分支上进行debug工作。`master`分支可供大家参考。



------

Cache部分详见`cache/`。

CPU主体部分详见`superscalar_inorder_dual/`。

可用`scripts/superscalar-inorder.tcl`在大赛提供的func test或perf test工程中快速添加源代码及IP核的配置文件。