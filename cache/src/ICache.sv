`include "instr_bus.svh"
`include "cache_bus.svh"

module ICache #(
    parameter int IDX_BITS    = 3,
    parameter int INDEX_BITS  = 6,
    parameter int OFFSET_BITS = 3,
    parameter int ALIGN_BITS  = 3,

    localparam int LINE_LENGTH     = 2**OFFSET_BITS,
    localparam int DATA_BYTES      = 2**ALIGN_BITS,
    localparam int DATA_WIDTH      = DATA_BYTES * 8,
    localparam int CBUS_DATA_ORDER = $clog2(CBUS_DATA_BYTES),
    localparam int SHAMT_BITS      = ALIGN_BITS - CBUS_DATA_ORDER,
    localparam int NUM_WAYS        = 2**IDX_BITS,
    localparam int NUM_SETS        = 2**INDEX_BITS,
    localparam int MAX_SHAMT       = 2**SHAMT_BITS - 1,
    localparam int COUNT_BITS      = OFFSET_BITS + ALIGN_BITS,

    // for BRAM, the size of "iaddr_t"
    localparam int MEM_ADDR_BITS = IDX_BITS + INDEX_BITS + OFFSET_BITS,

    // NOTE: in order to utilize VIPT, NONTAG_BITS must be within 4KB page.
    localparam int NONTAG_BITS = INDEX_BITS + COUNT_BITS,
    localparam int TAG_BITS    = BITS_PER_WORD - NONTAG_BITS,

    localparam type data_t   = logic [DATA_WIDTH - 1:0],
    localparam type shamt_t  = logic [SHAMT_BITS - 1:0],
    localparam type offset_t = logic [OFFSET_BITS - 1:0],
    localparam type index_t  = logic [INDEX_BITS - 1:0],
    localparam type idx_t    = logic [IDX_BITS - 1:0],
    localparam type tag_t    = logic [TAG_BITS - 1:0],

    // icache expects 8 bytes alignment, but also accepts a shift value.
    // therefore, only the last two bits need to be zeros.
    localparam type zeros_t = logic [1:0],

    localparam type align_t = struct packed {
        shamt_t shamt;
        zeros_t zeros;
    },
    localparam type count_t = struct packed {
        offset_t offset;
        shamt_t  shamt;
    },
    localparam type addr_t = struct packed {
        tag_t    tag;
        index_t  index;
        offset_t offset;
        align_t  aligned;
    },
    localparam type iaddr_t = struct packed {
        idx_t    idx;
        index_t  index;
        offset_t offset;
    },
    localparam type line_t = struct packed {
        logic valid;
        tag_t tag;
    },

    // for tree-based PLRU
    localparam type select_t = logic [NUM_WAYS - 2:0],
    localparam type set_t    = struct packed {
        select_t                select;
        line_t [NUM_WAYS - 1:0] lines;
    }
) (
    input logic clk, resetn,

    input  addr_t      ibus_req_vaddr,
    input  ibus_req_t  ibus_req,
    output ibus_resp_t ibus_resp,
    output cbus_req_t  cbus_req,
    input  cbus_resp_t cbus_resp
);
    /**
     * process request address
     * related signals/variables are prefixed with "req_"
     */
    // address parsing
    addr_t req_vaddr, req_paddr;
    assign req_vaddr = ibus_req_vaddr;
    assign req_paddr = ibus_req.addr;

    // set info storage
    set_t [NUM_SETS - 1:0] sets;
    set_t req_set;
    assign req_set = sets[req_vaddr.index];  // virtually indexed

    // full associative search
    // part 1: hit tests
    logic req_hit;
    logic [NUM_WAYS - 1:0] req_hit_bits;

    assign req_hit = |req_hit_bits;
    for (genvar i = 0; i < NUM_WAYS; i++) begin
        assign req_hit_bits[i] = req_paddr.tag == req_set.lines[i].tag;
    end

    // part 2: one-hot to binary decoder
    idx_t req_idx;
    always_comb begin
        req_idx = 0;
        for (int i = 0; i < NUM_WAYS; i++) begin
            req_idx |= req_hit_bits[i] ? idx_t'(i) : 0;
        end
    end

    // perform replacement algorithm
    idx_t    req_victim_idx;
    select_t req_new_select;
    PLRU #(
        .NUM_WAYS(NUM_WAYS)
    ) replacement_inst(
        .select(req_set.select),
        .idx(req_victim_idx),
        .new_select(req_new_select)
    );

    // generate cache BRAM address
    iaddr_t req_iaddr;
    assign req_iaddr.idx    = req_idx;
    assign req_iaddr.index  = req_paddr.index;
    assign req_iaddr.offset = req_paddr.offset;

    /**
     * hit stage
     *
     * "hit_data_ok" & "hit_resp_index" are expected to be a register.
     * "addr_ok" is responded in the last clock cycle.
     * the "hit_pos" is sent to BRAM, which has a register at the input.
     * BRAM will provide the read data at the same time.
     */
    logic       hit_data_ok;
    logic       hit_resp_index;

    iaddr_t     hit_pos;
    ibus_data_t hit_data;
    assign hit_pos = req_iaddr;

    /**
     * miss stage
     */
    localparam int WIDTH_RATIO = DATA_WIDTH / CBUS_DATA_WIDTH;

    typedef logic [DATA_BYTES  - 1:0] bram_wrten_t;
    typedef logic [WIDTH_RATIO - 1:0] ready_bits_t;

    localparam bram_wrten_t MISS_MASK = {
        {(DATA_BYTES - CBUS_DATA_BYTES){1'b0}},
        {CBUS_DATA_BYTES{1'b1}}
    };

    // NOTE: "miss_pos.idx" & "miss_pos.index" are stage registers,
    //       but "miss_pos.offset" is driven by "miss_count".
    //
    //       however, this results in BLKANDNBLK in Verilator, who recommends
    //       simply ignore this error. Although we try to split the variable instead.
    //       It may prevent us monitoring the variable, in which case please
    //       replace it with a "lint_off".
    logic   miss_busy;
    addr_t  miss_addr;
    iaddr_t miss_pos /* verilator split_var */;
    count_t miss_count;

    // wires
    // "miss_busy": current cycle
    // "miss_avail": next cycle
    logic        miss_avail;
    logic        miss_data_last;  // is the last data of a cache word?
    bram_wrten_t miss_write_en;
    data_t       miss_wdata;
    data_t       miss_rdata;      // no use

    assign miss_avail      = !miss_busy || cbus_resp.last;
    assign miss_data_last  = miss_count.shamt == {SHAMT_BITS{1'b1}};
    assign miss_pos.offset = miss_count.offset;
    assign miss_write_en   = cbus_resp.okay ?
        (MISS_MASK << miss_count.shamt) : bram_wrten_t'(0);

    for (genvar i = 0; i < WIDTH_RATIO; i++) begin: miss_wdata_echo
        localparam int hi = CBUS_DATA_WIDTH * (i + 1) - 1;
        localparam int lo = CBUS_DATA_WIDTH * i;
        assign miss_wdata[hi:lo] = cbus_resp.rdata;
    end

    // ready bits
    ready_bits_t [LINE_LENGTH - 1:0] miss_mark;
    ready_bits_t [LINE_LENGTH - 1:0] miss_ready;

    for (genvar i = 0; i < LINE_LENGTH; i++) begin: miss_presum
        PrefixSum #(
            .ARRAY_LENGTH(WIDTH_RATIO)
        ) fenwick_inst(.arr(miss_mark[i]), .sum(miss_ready[i]));
    end

    /**
     * determine whether the data is ready
     */
    count_t req_count;
    assign req_count.offset = req_iaddr.offset;
    assign req_count.shamt  = req_paddr.aligned.shamt;

    logic req_in_miss, req_miss_ready, req_ready;
    assign req_in_miss = miss_busy &&
        req_iaddr.idx == miss_pos.idx && req_iaddr.index == miss_pos.index;
    assign req_miss_ready =
        miss_ready[req_count.offset][req_count.shamt] ||
        (req_count.offset == miss_count.offset && miss_data_last);  // include pending write
    assign req_ready = req_hit && (!req_in_miss || req_miss_ready);

    logic req_to_hit, req_to_miss;
    assign req_to_hit = ibus_req.req && req_ready;
    assign req_to_miss = miss_avail && !req_hit;

    /**
     * the BRAM
     * port 1 is used for read only
     * port 2 is used for miss replacement
     */
    DualPortBRAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(MEM_ADDR_BITS)
    ) bram_inst(
        .clk(clk), .reset(~resetn), .en(1),

        .write_en_1(0),
        .addr_1(hit_pos),
        .data_in_1(0),
        .data_out_1(hit_data),

        .write_en_2(miss_write_en),
        .addr_2(miss_pos),
        .data_in_2(miss_wdata),
        .data_out_2(miss_rdata)
    );

    /**
     * pipelining & state transitions
     */
    always_ff @(posedge clk)
    if (resetn) begin
        // to hit stage
        hit_data_ok    <= req_to_hit;
        hit_resp_index <= req_paddr.aligned.shamt;

        // update hit stage
        if (req_to_hit) begin
            for (int i = 0; i < NUM_SETS; i++) begin
                sets[i].lines <= sets[i].lines;
                sets[i].select <= req_iaddr.idx == idx_t'(i) ?
                    req_new_select : sets[i].select;
            end
        end

        // to miss stage
        miss_busy <= req_to_miss;
        if (req_to_miss) begin
            miss_addr      <= req_paddr;
            miss_pos.idx   <= req_victim_idx;
            miss_pos.index <= req_iaddr.index;
        end

        // update miss stage
        if (cbus_resp.okay) begin
            for (int i = 0; i < LINE_LENGTH; i++)
            for (int j = 0; j <= MAX_SHAMT; j++) begin
                miss_mark[i][j] <= (
                        miss_count.offset == offset_t'(i) &&
                        miss_count.shamt  == shamt_t'(j)
                    ) ? 1 : miss_mark[i][j];
            end

            miss_count <= miss_count + 1;
        end
    end else begin
        for (int i = 0; i < NUM_SETS; i++) begin
            sets[i].select <= 0;
            for (int j = 0; j < NUM_WAYS; j++) begin
                sets[i].lines[j].valid <= 0;
            end
        end

        hit_data_ok    <= 0;
        hit_resp_index <= 0;
        miss_busy      <= 0;
    end

    /**
     * instr bus driver
     */
    assign ibus_resp.addr_ok = req_ready;
    assign ibus_resp.data_ok = hit_data_ok;
    assign ibus_resp.data    = hit_data;
    assign ibus_resp.index   = hit_resp_index;

    /**
     * cache bus driver
     */
    assign cbus_req.valid    = miss_busy;
    assign cbus_req.is_write = 0;
    assign cbus_req.addr     = miss_addr;
    assign cbus_req.order    = cbus_order_t'(COUNT_BITS - CBUS_DATA_ORDER);
    assign cbus_req.wdata    = 0;

    /**
     * unused (for Verilator)
     */
    logic __unused_ok = &{1'b0,
        req_vaddr, miss_rdata,
    1'b0};
endmodule