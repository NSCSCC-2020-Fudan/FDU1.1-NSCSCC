`include "instr_bus.svh"
`include "cache_bus.svh"

module ICache #(
`ifndef IN_SIMULATION
    // 8-way 32KB configuration:
    parameter int IDX_BITS    = 3,
    parameter int INDEX_BITS  = 6,
    parameter int OFFSET_BITS = 3,
    parameter int ALIGN_BITS  = 3,
`else
    // for simulation: 8-way 1KB
    parameter int IDX_BITS    = 3,
    parameter int INDEX_BITS  = 2,
    parameter int OFFSET_BITS = 2,
    parameter int ALIGN_BITS  = 3,
`endif

    localparam int LINE_LENGTH     = 2**OFFSET_BITS,
    localparam int DATA_BYTES      = 2**ALIGN_BITS,
    localparam int DATA_WIDTH      = DATA_BYTES * 8,
    localparam int CBUS_DATA_ORDER = $clog2(CBUS_DATA_BYTES),
    localparam int SHAMT_BITS      = ALIGN_BITS - CBUS_DATA_ORDER,
    localparam int NUM_WAYS        = 2**IDX_BITS,
    localparam int NUM_SETS        = 2**INDEX_BITS,
    localparam int COUNT_BITS      = OFFSET_BITS + SHAMT_BITS,
    localparam int MAX_COUNT       = 2**(COUNT_BITS) - 1,

    // for BRAM, the size of "iaddr_t"
    localparam int MEM_ADDR_BITS = IDX_BITS + INDEX_BITS + OFFSET_BITS,

    // NOTE: in order to utilize VIPT, NONTAG_BITS must be within 4KB page.
    localparam int NONTAG_BITS = INDEX_BITS + OFFSET_BITS + ALIGN_BITS,
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

    localparam type record_t = struct packed {
        logic valid;
    },
    localparam type meta_t   = record_t [NUM_WAYS - 1:0],
    localparam type bundle_t = tag_t    [NUM_WAYS - 1:0],
    localparam type select_t = logic [NUM_WAYS - 2:0]
) (
    input logic clk, resetn,

    input  addr_t      ibus_req_vaddr,
    input  ibus_req_t  ibus_req,
    output ibus_resp_t ibus_resp,
    output cbus_req_t  cbus_req,
    input  cbus_resp_t cbus_resp
);
    cache_op_t cop;
    assign cop.req   = ibus_req.req && ibus_req.cache_op.req;
    assign cop.funct = ibus_req.cache_op.funct;

    /**
     * storages for cache tags & records
     */
    meta_t   ram_meta,   ram_new_meta;
    bundle_t ram_tags,   ram_new_tags;
    select_t ram_select, ram_new_select;

    FFRAM #(
        .DATA_WIDTH($bits(meta_t)),
        .ADDR_WIDTH(INDEX_BITS)
    ) ram_meta_inst(
        .clk(clk), .resetn(resetn), .write_en(1),
        .addr(ibus_req_vaddr.index),
        .data_in(ram_new_meta),
        .data_out(ram_meta)
    );
    LUTRAM #(
        .DATA_WIDTH($bits(bundle_t)),
        .ADDR_WIDTH(INDEX_BITS),
        .ENABLE_BYTE_WRITE(0)
    ) ram_tags_inst(
        .clk(clk), .write_en(1),
        .addr(ibus_req_vaddr.index),
        .data_in(ram_new_tags),
        .data_out(ram_tags)
    );
    LUTRAM #(
        .DATA_WIDTH($bits(select_t)),
        .ADDR_WIDTH(INDEX_BITS),
        .ENABLE_BYTE_WRITE(0)
    ) ram_select_inst(
        .clk(clk), .write_en(1),
        .addr(ibus_req_vaddr.index),
        .data_in(ram_new_select),
        .data_out(ram_select)
    );

    /**
     * process request address
     * related signals/variables are prefixed with "req_"
     */
    // address parsing
    addr_t req_vaddr, req_paddr;
    assign req_vaddr = ibus_req_vaddr;
    assign req_paddr = ibus_req.addr;

    // full associative search
    // part 1: hit tests
    logic [NUM_WAYS - 1:0] req_hit_bits;
    logic req_hit;
    idx_t req_idx;

    assign req_hit = |req_hit_bits;
    for (genvar i = 0; i < NUM_WAYS; i++) begin
        assign req_hit_bits[i] = ram_meta[i].valid &&
            req_paddr.tag == ram_tags[i];
    end

    OneHotToBinary #(.SIZE(NUM_WAYS)) _decoder_inst(
        .vec(req_hit_bits), .idx(req_idx)
    );

    // perform replacement algorithm
    idx_t    req_victim_idx;
    select_t req_new_select;
    PLRU #(
        .NUM_WAYS(NUM_WAYS)
    ) replacement_inst(
        .select(ram_select),
        .victim_idx(req_victim_idx),
        .idx(req_idx),
        .new_select(req_new_select)
    );

    // generate cache BRAM address
    iaddr_t req_iaddr;
    assign req_iaddr.idx    = req_idx;
    assign req_iaddr.index  = req_vaddr.index;
    assign req_iaddr.offset = req_vaddr.offset;

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
    localparam int WIDTH_RATIO     = DATA_WIDTH / CBUS_DATA_WIDTH;
    localparam int READY_BITS      = LINE_LENGTH * WIDTH_RATIO;
    localparam int CBUS_ALIGN_BITS = $clog2(CBUS_DATA_BYTES);

    typedef logic [DATA_BYTES - 1:0] bram_wrten_t;
    typedef logic [READY_BITS - 1:0] ready_bits_t;

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
    bram_wrten_t miss_write_en;
    data_t       miss_wdata;

    assign miss_avail      = !miss_busy || cbus_resp.last;
    assign miss_pos.offset = miss_count.offset;
    assign miss_write_en   = cbus_resp.okay ?
        (MISS_MASK << {miss_count.shamt, {CBUS_ALIGN_BITS{1'b0}}}) :
        bram_wrten_t'(0);

    for (genvar i = 0; i < WIDTH_RATIO; i++) begin: miss_wdata_echo
        localparam int hi = CBUS_DATA_WIDTH * (i + 1) - 1;
        localparam int lo = CBUS_DATA_WIDTH * i;
        assign miss_wdata[hi:lo] = cbus_resp.rdata;
    end

    // ready bits
    ready_bits_t miss_mark, miss_ready;

    for (genvar i = 0; i < LINE_LENGTH; i++) begin: miss_presum
        localparam int hi = WIDTH_RATIO * (i + 1) - 1;
        localparam int lo = WIDTH_RATIO * i;
        PrefixSum #(
            .ARRAY_LENGTH(WIDTH_RATIO)
        ) fenwick_inst(
            .arr(miss_mark[hi:lo]),
            .sum(miss_ready[hi:lo])
        );
    end

    /**
     * determine whether the data is ready
     */
    count_t req_count;
    assign req_count.offset = req_iaddr.offset;
    assign req_count.shamt  = req_paddr.aligned.shamt;

    logic req_in_miss, req_miss_ready;
    assign req_in_miss = miss_busy &&
        /* req_iaddr.idx == miss_pos.idx && */  // to reduce latency
        req_paddr.tag == miss_addr.tag &&
        req_iaddr.index == miss_pos.index;

    assign req_miss_ready = !req_in_miss || miss_ready[req_count];

    logic req_to_hit, req_to_miss;
    assign req_to_hit  =  req_hit && (!cop.req && ibus_req.req && req_miss_ready);
    assign req_to_miss = !req_hit && (!cop.req && ibus_req.req && miss_avail);

    /**
     * the BRAM
     * port 1 is used for read only
     * port 2 is used for miss replacement
     *
     * [deprecated] "bram_out_port": a register, to avoid read/write collision.
     *
     * TODO: maybe simple dual port bram is more appropriate.
     */
    // logic bram_out_port;
    // logic bram_addr_eq, bram_on_write;
    // ibus_data_t [1:0] bram_data;
    ibus_data_t unused_data;

    DualPortBRAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(MEM_ADDR_BITS),
        .WRITE_MODE("read_first")
    ) bram_inst(
        .clk(clk), .reset(~resetn),
        .en_1(1), .en_2(1),

        .write_en_1(0),
        .addr_1(hit_pos),
        .data_in_1(0),
        // .data_out_1(bram_data[0]),
        .data_out_1(hit_data),

        .write_en_2(miss_write_en),
        .addr_2(miss_pos),
        .data_in_2(miss_wdata),
        // .data_out_2(bram_data[1])
        .data_out_2(unused_data)
    );

    // assign bram_addr_eq = hit_pos == miss_pos;
    // assign bram_on_write = |miss_write_en;
    // assign hit_data = bram_data[0];

    /**
     * cache operations
     */
    logic cop_busy;
    logic cop_ready;
    idx_t cop_raw_idx;
    idx_t cop_idx;

    assign cop_busy    = miss_busy;
    assign cop_ready   = cop.req && !cop_busy;
    assign cop_raw_idx = idx_t'(req_vaddr.tag);
    assign cop_idx     = cop.funct.as_index ? cop_raw_idx : req_idx;

    /**
     * pipelining & state transitions
     */
    // LUTRAM updates
    assign ram_new_select = req_to_hit ? req_new_select : ram_select;

    always_comb
    unique if (cop_ready) begin
        for (int i = 0; i < NUM_WAYS; i++) begin
            if (cop_idx == idx_t'(i))
                ram_new_meta[i].valid = cop.funct.invalidate ? 0 : ram_meta[i].valid;
            else
                ram_new_meta[i] = ram_meta[i];
        end

        ram_new_tags = ram_tags;
    end else if (req_to_miss) begin
        for (int i = 0; i < NUM_WAYS; i++) begin
            if (req_victim_idx == idx_t'(i)) begin
                ram_new_meta[i] = 1;
                ram_new_tags[i] = req_paddr.tag;
            end else begin
                ram_new_meta[i] = ram_meta[i];
                ram_new_tags[i] = ram_tags[i];
            end
        end
    end else begin
        ram_new_meta   = ram_meta;
        ram_new_tags   = ram_tags;
    end

    // FSM updates
    always_ff @(posedge clk)
    if (resetn) begin
        // bram_out_port <= (bram_addr_eq && bram_on_write) ? 1 : 0;

        // to hit stage
        hit_data_ok    <= req_to_hit || cop_ready;
        hit_resp_index <= req_paddr.aligned.shamt;

        // update miss stage
        // NOTE: "req_to_miss" needs to reset "miss_mark" & "miss_count"
        if (cbus_resp.okay) begin
            for (int i = 0; i <= MAX_COUNT; i++) begin
                miss_mark[i] <=
                    (miss_count == count_t'(i)) ? 1 : miss_mark[i];
            end

            miss_count <= miss_count + 1;
        end

        // to miss stage
        miss_busy <= miss_avail ? req_to_miss : 1;
        if (req_to_miss) begin
            miss_addr         <= req_paddr;
            // for INCR burst
            // miss_addr         <= {req_paddr.tag, req_paddr.index, offset_t'(0), align_t'(0)};
            miss_pos.idx      <= req_victim_idx;
            miss_pos.index    <= req_iaddr.index;
            miss_count.offset <= req_iaddr.offset;
            miss_count.shamt  <= req_paddr.aligned.shamt;
            // for INCR burst
            // miss_count.offset <= 0;
            // miss_count.shamt  <= 0;
            miss_mark         <= 0;
        end
    end else begin
        hit_data_ok    <= 0;
        hit_resp_index <= 0;
        miss_busy      <= 0;
    end

    /**
     * instr bus driver
     */
    assign ibus_resp.addr_ok = cop.req ? !cop_busy : (req_hit && req_miss_ready);
    assign ibus_resp.data_ok = hit_data_ok;
    assign ibus_resp.data    = hit_data;
    assign ibus_resp.index   = hit_resp_index;

    /**
     * cache bus driver
     */
    assign cbus_req.valid    = miss_busy;
    assign cbus_req.is_write = 0;
    assign cbus_req.addr     = miss_addr;
    assign cbus_req.order    = cbus_order_t'(COUNT_BITS);
    assign cbus_req.wdata    = 0;

    /**
     * unused (for Verilator)
     */
    logic __unused_ok = &{1'b0,
        req_vaddr, unused_data, ibus_req, /*req_paddr,*/
    1'b0};
endmodule