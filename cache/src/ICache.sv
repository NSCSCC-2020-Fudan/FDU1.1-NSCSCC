`include "icache.svh"
`include "instr_bus.svh"
`include "cache_bus.svh"

module ICache(
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
    icache_addr_t req_vaddr, req_paddr;
    assign req_vaddr = ibus_req_vaddr;
    assign req_paddr = ibus_req.addr;

    // set info storage
    icache_set_t [ICACHE_NUM_SETS - 1:0] sets;
    icache_set_t req_set;
    assign req_set = sets[req_vaddr.index];  // virtually indexed

    // full associative search
    // part 1: hit tests
    logic req_hit;
    logic [ICACHE_NUM_WAYS - 1:0] req_hit_bits;

    assign req_hit = |req_hit_bits;
    for (genvar i = 0; i < ICACHE_NUM_WAYS; i++) begin
        assign req_hit_bits[i] = req_paddr.tag == req_set.lines[i].tag;
    end

    // part 2: one-hot to binary decoder
    icache_idx_t req_idx;
    always_comb begin
        req_idx = 0;
        for (int i = 0; i < ICACHE_NUM_WAYS; i++) begin
            req_idx |= req_hit_bits[i] ? icache_idx_t'(i) : 0;
        end
    end

    // perform replacement algorithm
    icache_idx_t    req_victim_idx;
    icache_select_t req_new_select;
    PLRU #(
        .NUM_WAYS(ICACHE_NUM_WAYS)
    ) replacement_inst(
        .select(req_set.select),
        .idx(req_victim_idx),
        .new_select(req_new_select)
    );

    // generate cache BRAM address
    icache_iaddr_t req_iaddr;
    assign req_iaddr.idx    = req_idx;
    assign req_iaddr.index  = req_paddr.index;
    assign req_iaddr.offset = req_paddr.offset;

    // determine whether the data is ready
    logic req_ready;
    assign req_ready = req_hit;

    /**
     * hit stage
     *
     * "hit_data_ok" & "hit_resp_index" are expected to be a register.
     * "addr_ok" is responded in the last clock cycle.
     * the "hit_pos" is sent to BRAM, which has a register at the input.
     * BRAM will provide the read data at the same time.
     */
    logic          hit_data_ok;
    logic          hit_resp_index;
    icache_iaddr_t hit_pos;
    ibus_data_t    hit_data;
    assign hit_pos = req_iaddr;

    /**
     * miss stage
     */
    typedef logic [ICACHE_DATA_BYTES - 1:0] bram_wrten_t;

    localparam int WIDTH_RATIO = ICACHE_DATA_WIDTH / CBUS_DATA_WIDTH;
    localparam bram_wrten_t MISS_MASK = {
        {(ICACHE_DATA_BYTES - CBUS_DATA_BYTES){1'b0}},
        {CBUS_DATA_BYTES{1'b1}}
    };

    // NOTE: "miss_pos.idx" & "miss_pos.index" are stage registers,
    //       but "miss_pos.offset" is driven by "miss_count".
    logic          miss_busy;
    icache_addr_t  miss_addr;
    icache_iaddr_t miss_pos;
    icache_count_t miss_count;

    // wires
    logic          miss_avail;
    bram_wrten_t   miss_write_en;
    icache_data_t  miss_wdata;
    icache_data_t  miss_rdata;  // no use

    // TODO: miss_ready, fenwick tree suffix calculation

    assign miss_avail = !miss_busy || cbus_resp.last;
    assign miss_pos.offset = miss_count.offset;
    assign miss_write_en = cbus_resp.okay ?
        (MISS_MASK << miss_count.shamt) :
        bram_wrten_t'(0);

    for (genvar i = 0; i < WIDTH_RATIO; i++) begin: miss_wdata_echo
        localparam int lo = CBUS_DATA_WIDTH * i;
        localparam int hi = CBUS_DATA_WIDTH * (i + 1) - 1;
        assign miss_wdata[hi:lo] = cbus_resp.rdata;
    end

    /**
     * the BRAM
     * port 1 is used for read only
     * port 2 is used for miss replacement
     */
    DualPortBRAM #(
        .DATA_WIDTH(ICACHE_DATA_WIDTH),
        .ADDR_WIDTH(ICACHE_MEM_ADDR_BITS)
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
        hit_data_ok <= req_ready;
        hit_resp_index <= req_vaddr.aligned.shamt;

        if (miss_busy)
            miss_count <= miss_count + 1;
    end else begin
        for (int i = 0; i < ICACHE_NUM_SETS; i++) begin
            sets[i].select <= 0;
            for (int j = 0; j < ICACHE_NUM_WAYS; j++) begin
                sets[i].lines[j].valid <= 0;
            end
        end
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
    assign cbus_req.valid = miss_busy;
    assign cbus_req.is_write = 0;
    assign cbus_req.addr = miss_addr;
    assign cbus_req.order = cbus_order_t'(ICACHE_OFFSET_BITS + ICACHE_ALIGN_BITS - 2);
    assign cbus_req.wdata = 0;

    logic __unused_ok = &{1'b0, miss_rdata, 1'b0};
endmodule