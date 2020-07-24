`include "defs.svh"

/**
 * refer to "DualPortBRAM.sv" for some behavioral model notes.
 *
 * Default configuration: 4KB / 32bit width / write-first
 */

// verilator lint_off VARHIDDEN
module SimpleDualPortBRAM #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 10,

    parameter `STRING RESET_VALUE = "00000000",
    parameter `STRING WRITE_MODE  = "write_first",

    localparam int MEM_NUM_WORDS  = 2**ADDR_WIDTH,
    localparam int BYTES_PER_WORD = DATA_WIDTH / 8,
    localparam int MEM_NUM_BYTES  = MEM_NUM_WORDS * BYTES_PER_WORD,
    localparam int MEM_NUM_BITS   = MEM_NUM_WORDS * DATA_WIDTH,

    localparam type addr_t  = logic  [ADDR_WIDTH     - 1:0],
    localparam type word_t  = logic  [DATA_WIDTH     - 1:0],
    localparam type wrten_t = logic  [BYTES_PER_WORD - 1:0],
    localparam type view_t  = byte_t [BYTES_PER_WORD - 1:0]
) (
    input logic clk, resetn, en,

    input  addr_t  raddr, waddr,
    input  wrten_t write_en,
    input  word_t  wdata,
    output word_t  rdata
);
    // xpm_memory_sdpram: Simple Dual Port RAM
    // Xilinx Parameterized Macro, version 2019.2
    xpm_memory_sdpram #(
        .ADDR_WIDTH_A(ADDR_WIDTH),
        .ADDR_WIDTH_B(ADDR_WIDTH),
        .AUTO_SLEEP_TIME(0),
        .BYTE_WRITE_WIDTH_A(8),  // byte-write enable
        .CASCADE_HEIGHT(0),
        .CLOCKING_MODE("common_clock"),
        .ECC_MODE("no_ecc"),
        .MEMORY_INIT_FILE("none"),
        .MEMORY_INIT_PARAM("0"),
        .MEMORY_OPTIMIZATION("true"),
        .MEMORY_PRIMITIVE("block"),  // expect BRAM
        .MEMORY_SIZE(MEM_NUM_BITS),  //in bits
        .MESSAGE_CONTROL(1),  // disable message reporting
        .READ_DATA_WIDTH_B(DATA_WIDTH),
        .READ_LATENCY_B(1),
        .READ_RESET_VALUE_B(RESET_VALUE),
        .RST_MODE_A("SYNC"),
        .RST_MODE_B("SYNC"),
        .SIM_ASSERT_CHK(1),
        .USE_EMBEDDED_CONSTRAINT(0),
        .USE_MEM_INIT(1),
        .WAKEUP_TIME("disable_sleep"),
        .WRITE_DATA_WIDTH_A(DATA_WIDTH),
        .WRITE_MODE_B(WRITE_MODE)
    ) xpm_memory_sdpram_inst (
        .clka(clk), .clkb(clk),
        .ena(en), .enb(en), .rstb(~resetn),
        .injectdbiterra(0),
        .injectsbiterra(0),
        .regceb(1),
        .sleep(0),

        .addrb(raddr),
        .doutb(rdata),
        .addra(waddr),
        .wea(write_en),
        .dina(wdata)
    );
    // End of xpm_memory_sdpram_inst instantiation
endmodule