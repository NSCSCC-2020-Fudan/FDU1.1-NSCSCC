`include "defs.svh"

/**
 * In verilator, use the behavioral model.
 * Otherwise XPM_MEMORY_TDPRAM will be enabled.
 *
 * NOTE: the "reset" signal does not reset the entire memory,
 *       it just reset the output to `RESET_VALUE`.
 *
 * Default configuration: 4KB / 32bit width / write-first
 */

// verilator lint_off VARHIDDEN
module DualPortBRAM #(
    parameter int DATA_WIDTH  = 32,
    parameter int ADDR_WIDTH  = 10,

    parameter `STRING RESET_VALUE = "00000000",
    parameter `STRING WRITE_MODE  = "write_first",

    localparam int MEM_NUM_WORDS  = 2**ADDR_WIDTH,
    localparam int BYTES_PER_WORD = DATA_WIDTH / 8,
    localparam int MEM_NUM_BYTES  = MEM_NUM_WORDS * BYTES_PER_WORD,
    localparam int MEM_NUM_BITS   = MEM_NUM_WORDS * DATA_WIDTH,

    localparam type addr_t  = logic [ADDR_WIDTH - 1:0],
    localparam type wrten_t = logic [BYTES_PER_WORD - 1:0],
    localparam type word_t  = logic [DATA_WIDTH - 1:0],
    localparam type view_t  = union packed {
        byte_t [BYTES_PER_WORD - 1:0] bytes;
        word_t word;
    }
) (
    input logic clk, reset, en,

    // port 1
    input  wrten_t write_en_1,
    input  addr_t  addr_1,
    input  word_t  data_in_1,
    output word_t  data_out_1,

    // port 2
    input  wrten_t write_en_2,
    input  addr_t  addr_2,
    input  word_t  data_in_2,
    output word_t  data_out_2
);
`ifdef VERILATOR
    localparam word_t _RESET_VALUE = word_t'(RESET_VALUE.atohex());
    localparam word_t DEADBEEF     = word_t'('hdeadbeef);

    `ASSERT(WRITE_MODE == "write_first", "Only \"write_first\" mode is supported.");

    logic reset_reg = 0;  // RST_MODE = "SYNC"
    addr_t addr_reg_1 = 0, addr_reg_2 = 0;
    view_t [MEM_NUM_WORDS - 1:0] mem = 0;

    // detect read/write collision
    logic addr_eq, hazard_1, hazard_2;
    logic hazard_reg_1 = 0, hazard_reg_2 = 0;
    assign addr_eq = addr_1 == addr_2;
    assign hazard_1 = addr_eq && |write_en_2;
    assign hazard_2 = addr_eq && |write_en_1;

    always_comb begin
        if (reset_reg) begin
            data_out_1 = _RESET_VALUE;
            data_out_2 = _RESET_VALUE;
        end else begin
            data_out_1 = hazard_reg_1 ?
                DEADBEEF : mem[addr_reg_1].word;
            data_out_2 = hazard_reg_2 ?
                DEADBEEF : mem[addr_reg_2].word;
        end
    end

    always_ff @(posedge clk) begin
        reset_reg <= reset;

        if (en) begin
            {addr_reg_1, addr_reg_2} <= {addr_1, addr_2};
            {hazard_reg_1, hazard_reg_2} <= {hazard_1, hazard_2};

            for (int i = 0; i < BYTES_PER_WORD; i++) begin
                int hi = 8 * i + 7;
                if (write_en_1[i])
                    mem[addr_1].bytes[i] <= data_in_1[hi-:8];
                if (write_en_2[i])
                    mem[addr_2].bytes[i] <= data_in_2[hi-:8];
            end
        end
    end

`else

    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2019.2
    xpm_memory_tdpram #(
        .ADDR_WIDTH_A(ADDR_WIDTH),
        .ADDR_WIDTH_B(ADDR_WIDTH),
        .AUTO_SLEEP_TIME(0),
        .BYTE_WRITE_WIDTH_A(8),  // byte-write enable
        .BYTE_WRITE_WIDTH_B(8),
        .CASCADE_HEIGHT(0),
        .CLOCKING_MODE("common_clock"),
        .ECC_MODE("no_ecc"),
        .MEMORY_INIT_FILE("none"),
        .MEMORY_INIT_PARAM("0"),
        .MEMORY_OPTIMIZATION("true"),
        .MEMORY_PRIMITIVE("block"),  // specify BRAM
        .MEMORY_SIZE(MEM_NUM_BITS),  // in bits
        .MESSAGE_CONTROL(1),  // enable message reporting
        .READ_DATA_WIDTH_A(DATA_WIDTH),
        .READ_DATA_WIDTH_B(DATA_WIDTH),
        .READ_LATENCY_A(1),
        .READ_LATENCY_B(1),
        .READ_RESET_VALUE_A(RESET_VALUE),
        .READ_RESET_VALUE_B(RESET_VALUE),
        .RST_MODE_A("SYNC"),
        .RST_MODE_B("SYNC"),
        .SIM_ASSERT_CHK(1),
        .USE_EMBEDDED_CONSTRAINT(0),
        .USE_MEM_INIT(1),
        .WAKEUP_TIME("disable_sleep"),
        .WRITE_DATA_WIDTH_A(DATA_WIDTH),
        .WRITE_DATA_WIDTH_B(DATA_WIDTH),
        .WRITE_MODE_A(WRITE_MODE),
        .WRITE_MODE_B(WRITE_MODE)
    ) xpm_memory_tdpram_inst (
        .sleep(0),
        .clka(clk), .clkb(clk),
        .ena(en), .enb(en),
        .rsta(reset), .rstb(reset),
        .regcea(1), .regceb(1),
        .injectdbiterra(0),
        .injectdbiterrb(0),
        .injectsbiterra(0),
        .injectsbiterrb(0),

        // port 1/a
        .wea(write_en_1),
        .addra(addr_1),
        .dina(data_in_1),
        .douta(data_out_1),

        // port 2/b
        .web(write_en_2),
        .addrb(addr_2),
        .dinb(data_in_2),
        .doutb(data_out_2)
    );
    // End of xpm_memory_tdpram_inst instantiation

`endif
endmodule