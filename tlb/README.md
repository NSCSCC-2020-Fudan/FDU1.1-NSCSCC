# TLB

## Directory

- `src/`：
  - `include/`：SystemVerilog 头文件。
  - `util/`：源代码。

## MMU-related Interface

`tlb_` 开头的类型均定义在 `tlb/src/include/tlb_bus.svh` 

`mmu_` 开头的类型定义在 `cache/src/include/mmu_bus.svh`

以下均为 MMU module 下的接口，需要说明：

- `intst/data_addr` 为指令与数据访存时的虚址，均为 32 位，因与 Cache 部分沟通，双发射时不会出现两条指令访存（data）的情况。

- `asid`：指示（虚拟）地址空间，为 `CP0` 寄存器 `entryhi[7:0]` ，可以直接通过 `.asid` 访问 `tlb_entryhi_t` 中的 `asid`。

- `inst/data_mmu_result`：指令与数据访存时的返回结果。`mmu_result_t` 中 `invalid` 指示 TLB Invalid Exception，`modified` 指示 TLB Modified Exception，`miss` 指示 TLB Refill Exception

- `tlb_index`：`tlb_index_t` 中 `idx` 指示 TLB 指令读写的 TLB Entry，如果为 TLBWR 则由 `CP0` 中的 `Random` 寄存器赋值，否则为 `Index` 寄存器赋值（这两个寄存器均可以看作 `tlb_index_t`，`tlb_index.idx = TLBWR ? cp0.random.idx : cp0:index.idx`）。

- `tlb_we`：TLB 写允许（TLBWI 和 TLBWR）

- `tlb_wdata`：TLB 写入的 entry

  ```verilog
  assign tlb_wdata.compsec.pagemask = cp0.pagemask(tlb_pagemask_t).mask;
  assign tlb_wdata.compsec.vpn2 	  = cp0.entryhi(tlb_entryhi_t).vpn2;
  assign tlb_wdata.compsec.g		  = cp0.entrylo0.g & cp0.entrylo1.g;
  assign tlb_wdata.compsec.asid	  = cp0.entryhi.asid;
  assign tlb_wdata.transec[i].pfn(cc/d/v)	  = cp0.entrylo[i].pfn;
  ```

- `tlb_rdata`：根据 `tlb_index` 从 TLB 中读出的 entry

- `tlbp_entryhi`：`CP0` 中的 `entryhi` 寄存器

- `tlbp_index`：TLBP 返回的 Index

```verilog
	input   tlb_addr_t      inst_addr,    data_addr,
    input   tlb_asid_t      asid,
    output  mmu_result_t    inst_mmu_result, data_mmu_result,

    // for TLBWI, TLBR, TLBWR
    input   tlb_index_t     tlb_index,
    input   logic           tlb_we,
    input   tlb_entry_t     tlb_wdata,
    output  tlb_entry_t     tlb_rdata,

    // for TLBP
    input   tlb_entryhi_t   tlbp_entryhi,
    output  tlb_index_t     tlbp_index,
```

## ISA

以下指令均应在 Excute 阶段执行。

| 指令  | opcode |  func  |
| :---: | :----: | :----: |
| TLBR  | 010000 | 000001 |
| TLBP  | 010000 | 001000 |
| TLBWI | 010000 | 000010 |
| TLBWR | 010000 | 000110 |

## Exception

相关的内容建议查看 `reference/MIPS_Vol3`