`include "defs.svh"

/**
 * In verilator, use the behavioral model.
 * Otherwise XPM_MEMORY_TDPRAM will be enabled.
 *
 * Default configuration: 4KB / 32bit width / byte-write enabled
 */

// verilator lint_off VARHIDDEN
module SimpleDualPortLUTRAM #(
    parameter int   DATA_WIDTH        = 32,
    parameter int   ADDR_WIDTH        = 10,
    parameter logic ENABLE_BYTE_WRITE = 1,

    localparam int BYTE_WIDTH     = ENABLE_BYTE_WRITE ? 8 : DATA_WIDTH,
    localparam int BYTES_PER_WORD = DATA_WIDTH / BYTE_WIDTH,
    localparam int MEM_NUM_WORDS  = 2**ADDR_WIDTH,
    localparam int MEM_NUM_BITS   = MEM_NUM_WORDS * DATA_WIDTH,

    localparam type addr_t  = logic  [ADDR_WIDTH     - 1:0],
    localparam type wrten_t = logic  [BYTES_PER_WORD - 1:0],
    localparam type byte_t  = logic  [BYTE_WIDTH     - 1:0],
    localparam type bytes_t = byte_t [BYTES_PER_WORD - 1:0],
    localparam type word_t  = logic  [DATA_WIDTH     - 1:0],
    localparam type view_t  = union packed {
        bytes_t bytes;
        word_t  word;
    }
) (
    input  logic   clk,
    input  wrten_t write_en,
    input  addr_t  raddr, waddr,
    input  view_t  data_in,
    output word_t  data_out
);
`ifdef VERILATOR

    view_t [MEM_NUM_WORDS - 1:0] mem = 0;

    assign data_out = mem[raddr];

    always_ff @(posedge clk) begin
        for (int i = 0; i < BYTES_PER_WORD; i++) begin
            if (write_en[i])
                mem[waddr].bytes[i] <= data_in.bytes[i];
        end
    end

`else

    // xpm_memory_sdpram: Simple Dual Port RAM
    // Xilinx Parameterized Macro, version 2019.2
    xpm_memory_sdpram #(
        .ADDR_WIDTH_A(ADDR_WIDTH),
        .ADDR_WIDTH_B(ADDR_WIDTH),
        .AUTO_SLEEP_TIME(0),
        .BYTE_WRITE_WIDTH_A(BYTE_WIDTH),
        .CASCADE_HEIGHT(0),
        .CLOCKING_MODE("common_clock"),
        .ECC_MODE("no_ecc"),
        .MEMORY_INIT_FILE("none"),
        .MEMORY_INIT_PARAM("0"),
        .MEMORY_OPTIMIZATION("true"),
        .MEMORY_PRIMITIVE("distributed"),
        .MEMORY_SIZE(MEM_NUM_BITS),  //in bits
        .MESSAGE_CONTROL(0),  // disable message reporting
        .READ_DATA_WIDTH_B(DATA_WIDTH),
        .READ_LATENCY_B(0),
        .READ_RESET_VALUE_B("0"),
        .RST_MODE_A("SYNC"),
        .RST_MODE_B("SYNC"),
        .SIM_ASSERT_CHK(1),
        .USE_EMBEDDED_CONSTRAINT(0),
        .USE_MEM_INIT(1),
        .WAKEUP_TIME("disable_sleep"),
        .WRITE_DATA_WIDTH_A(DATA_WIDTH),
        .WRITE_MODE_B("read_first")
    ) xpm_memory_sdpram_inst (
        .clka(clk), .clkb(clk),
        .ena(1), .enb(1), .rstb(0),
        .injectdbiterra(0),
        .injectsbiterra(0),
        .regceb(1),
        .sleep(0),

        .addrb(raddr),
        .doutb(data_out),
        .addra(waddr),
        .wea(write_en),
        .dina(data_in)
    );
    // End of xpm_memory_sdpram_inst instantiation

`endif
endmodule