`include "defs.svh"

/**
 * In verilator, use the behavioral model.
 * Otherwise XPM_MEMORY_TDPRAM will be enabled.
 *
 * Default configuration: 4KB / 32bit width / byte-write enabled
 */

// verilator lint_off VARHIDDEN
module LUTRAM #(
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
    input  addr_t  addr,
    input  view_t  data_in,
    output word_t  data_out
);
`ifdef VERILATOR

    view_t [MEM_NUM_WORDS - 1:0] mem = 0;

    assign data_out = mem[addr];

    always_ff @(posedge clk) begin
        for (int i = 0; i < BYTES_PER_WORD; i++) begin
            if (write_en[i])
                mem[addr].bytes[i] <= data_in.bytes[i];
        end
    end

`else

    // xpm_memory_spram: Single Port RAM
    // Xilinx Parameterized Macro, version 2019.2
    xpm_memory_spram #(
        .ADDR_WIDTH_A(ADDR_WIDTH),
        .AUTO_SLEEP_TIME(0),
        .BYTE_WRITE_WIDTH_A(BYTE_WIDTH),
        .CASCADE_HEIGHT(0),
        .ECC_MODE("no_ecc"),
        .MEMORY_INIT_FILE("none"),
        .MEMORY_INIT_PARAM("0"),
        .MEMORY_OPTIMIZATION("true"),
        .MEMORY_PRIMITIVE("distributed"),
        .MEMORY_SIZE(MEM_NUM_BITS),
        .MESSAGE_CONTROL(0),
        .READ_DATA_WIDTH_A(DATA_WIDTH),
        .READ_LATENCY_A(0),
        .READ_RESET_VALUE_A("0"),
        .RST_MODE_A("SYNC"),
        .SIM_ASSERT_CHK(1),
        .USE_MEM_INIT(0),
        .WAKEUP_TIME("disable_sleep"),
        .WRITE_DATA_WIDTH_A(DATA_WIDTH),
        .WRITE_MODE_A("read_first")
    ) xpm_memory_spram_inst (
        .clka(clk),
        .addra(addr),
        .wea(write_en),
        .dina(data_in),
        .douta(data_out),

        .ena(1),
        .regcea(1),
        .rsta(0),
        .sleep(0),
        .injectdbiterra(0),
        .injectsbiterra(0)
    );
    // End of xpm_memory_spram_inst instantiation

`endif
endmodule