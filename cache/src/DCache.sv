`include "data_bus.svh"
`include "cache_bus.svh"

module DCache #(
`ifndef IN_SIMULATION
    // 8-way 32KB configuration:
    parameter int IDX_BITS    = 3,
    parameter int INDEX_BITS  = 6,
    parameter int OFFSET_BITS = 4,
`else
    // for simulation: 8-way 512B
    parameter int IDX_BITS    = 3,
    parameter int INDEX_BITS  = 2,
    parameter int OFFSET_BITS = 2,
`endif

    localparam int DATA_WIDTH  = DBUS_DATA_WIDTH,
    localparam int DATA_BYTES  = DBUS_DATA_BYTES,
    localparam int ALIGN_BITS  = $clog2(DBUS_DATA_BYTES),  // accord with DBus settings
    localparam int IADDR_BITS  = IDX_BITS + INDEX_BITS + OFFSET_BITS,
    localparam int NONTAG_BITS = INDEX_BITS + OFFSET_BITS + ALIGN_BITS,
    localparam int TAG_BITS    = DBUS_DATA_WIDTH - NONTAG_BITS,

    localparam int NUM_WORDS = 2**OFFSET_BITS,
    localparam int NUM_WAYS  = 2**IDX_BITS,
    localparam int NUM_SETS  = 2**INDEX_BITS,

    localparam type zeros_t  = logic [ALIGN_BITS - 1:0],
    localparam type offset_t = logic [OFFSET_BITS - 1:0],
    localparam type index_t  = logic [INDEX_BITS - 1:0],
    localparam type idx_t    = logic [IDX_BITS - 1:0],
    localparam type tag_t    = logic [TAG_BITS - 1:0],
    localparam type view_t   = dbus_view_t,
    localparam type wrten_t  = dbus_wrten_t,
    localparam type buffer_t = view_t [NUM_WORDS - 1:0],

    localparam type addr_t = struct packed {
        tag_t    tag;
        index_t  index;
        offset_t offset;
        zeros_t  zeros;
    },
    localparam type iaddr_t = struct packed {
        idx_t    idx;
        index_t  index;
        offset_t offset;
    },

    // set info storages
    localparam type record_t = struct packed {
        logic valid;
        logic dirty;
    },
    localparam type meta_t   = record_t [NUM_WAYS - 1:0],
    localparam type bundle_t = tag_t    [NUM_WAYS - 1:0],
    localparam type select_t = logic    [NUM_WAYS - 2:0]
) (
    input logic clk, resetn,

    input  addr_t      dbus_req_vaddr,
    input  dbus_req_t  dbus_req,
    output dbus_resp_t dbus_resp,
    output cbus_req_t  cbus_req,
    input  cbus_resp_t cbus_resp
);
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
        .addr(dbus_req_vaddr.index),
        .data_in(ram_new_meta),
        .data_out(ram_meta)
    );
    LUTRAM #(
        .DATA_WIDTH($bits(bundle_t)),
        .ADDR_WIDTH(INDEX_BITS),
        .ENABLE_BYTE_WRITE(0)
    ) ram_tags_inst(
        .clk(clk), .write_en(1),
        .addr(dbus_req_vaddr.index),
        .data_in(ram_new_tags),
        .data_out(ram_tags)
    );
    LUTRAM #(
        .DATA_WIDTH($bits(select_t)),
        .ADDR_WIDTH(INDEX_BITS),
        .ENABLE_BYTE_WRITE(0)
    ) ram_select_inst(
        .clk(clk), .write_en(1),
        .addr(dbus_req_vaddr.index),
        .data_in(ram_new_select),
        .data_out(ram_select)
    );

    /**
     * process request addresses
     */
    addr_t req_vaddr, req_paddr;
    assign req_vaddr = dbus_req_vaddr;
    assign req_paddr = dbus_req.addr;

    // full associative search
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

    // assignment later
    logic req_in_miss;
    logic req_miss_ready;
    logic req_to_hit;
    logic req_to_miss;

    /**
     * hit stage
     */
    logic hit_data_ok;

    iaddr_t hit_pos;
    view_t  hit_rdata;
    wrten_t hit_write_en;
    view_t  hit_wdata;

    assign hit_pos      = req_iaddr;
    assign hit_write_en = (dbus_req.valid && req_miss_ready) ?
        ({DBUS_DATA_BYTES{req_hit}} & dbus_req.write_en) : 0;
    assign hit_wdata    = dbus_req.data;

    /**
     * miss stage
     */
    typedef logic [NUM_WORDS - 1:0] ready_bits_t;

    localparam wrten_t BRAM_FULL_MASK = {DATA_BYTES{1'b1}};

    // state variables
    enum /*logic [1:0]*/ {  // hope Vivado uses one-hot encoding
        IDLE, READ, WRITE
    } miss_state;
    addr_t       miss_addr;
    iaddr_t      miss_pos;
    ready_bits_t miss_ready;

    // NOTE: victim buffer has one cycle delay
    record_t miss_vrecord;
    tag_t    miss_vtag;
    logic    miss_vwrten;
    offset_t miss_voffset;
    buffer_t miss_victim;

    // wires
    logic   miss_busy;
    logic   miss_avail;
    logic   miss_is_dirty;
    view_t  miss_rdata;
    wrten_t miss_write_en;
    view_t  miss_wdata;

    assign miss_busy     = miss_state != IDLE;
    assign miss_is_dirty = miss_vrecord.valid && miss_vrecord.dirty;
    assign miss_avail    = miss_state == IDLE || (miss_state == WRITE && cbus_resp.last);
    assign miss_write_en = miss_state == READ && cbus_resp.okay ? BRAM_FULL_MASK : 0;
    assign miss_wdata    = cbus_resp.rdata;

    /**
     * determine whether the data is ready
     */
    assign req_in_miss = miss_busy &&
        /* req_iaddr.idx == miss_pos.idx && */  // to reduce latency
        req_paddr.tag == miss_addr.tag &&
        req_iaddr.index == miss_pos.index;
    assign req_miss_ready = !req_in_miss || miss_ready[req_iaddr.offset];
    assign req_to_hit     = req_hit && (dbus_req.valid && req_miss_ready);
    assign req_to_miss    = dbus_req.valid && miss_avail && !req_hit;

    /**
     * the BRAM
     */
    DualPortBRAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(IADDR_BITS),
        .WRITE_MODE("read_first")  // for victim buffer
    ) bram_inst(
        .clk(clk), .reset(~resetn), .en(1),

        .write_en_1(hit_write_en),
        .addr_1(hit_pos),
        .data_in_1(hit_wdata),
        .data_out_1(hit_rdata),

        .write_en_2(miss_write_en),
        .addr_2(miss_pos),
        .data_in_2(miss_wdata),
        .data_out_2(miss_rdata)
    );

    /**
     * pipelining & state transitions
     */
    // LUTRAM updates
    assign ram_new_select = req_to_hit ? req_new_select : ram_select;

    always_comb
    unique if (req_to_hit) begin
        if (dbus_req.is_write) begin
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (req_iaddr.idx == idx_t'(i)) begin
                    ram_new_meta[i].dirty = 1;
                    ram_new_meta[i].valid = ram_meta[i].valid;
                end else
                    ram_new_meta[i] = ram_meta[i];
            end
        end else
            ram_new_meta = ram_meta;

        ram_new_tags   = ram_tags;
    end else if (req_to_miss) begin
        for (int i = 0; i < NUM_WAYS; i++) begin
            if (req_victim_idx == idx_t'(i)) begin
                ram_new_meta[i].valid = 1;
                ram_new_meta[i].dirty = 0;
                ram_new_tags[i]       = req_paddr.tag;
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
        // to hit stage
        hit_data_ok <= req_to_hit;

        // update miss stage
        // some changes may be overwritten by "req_to_miss"
        unique case (miss_state)
            READ: begin
                // when new data arrives, write the old value to victim buffer
                // in the next cycle.
                // this behavior is guaranteed by the "read_first" mode.
                miss_vwrten  <= cbus_resp.okay;
                miss_voffset <= miss_pos.offset;

                if (cbus_resp.last) begin
                    miss_state    <= miss_is_dirty ? WRITE : IDLE;
                    miss_addr.tag <= miss_vtag;
                end

                if (cbus_resp.okay) begin
                    miss_pos.offset <= offset_t'(miss_pos.offset + 1);  // ensure overflow

                    for (int i = 0; i < NUM_WORDS; i++) begin
                        miss_ready[i] <= miss_pos.offset == offset_t'(i) ?
                            1 : miss_ready[i];
                    end
                end
            end

            WRITE: begin
                // there may be one write to victim buffer from READ state.
                // after that, the victim buffer will be available for writeback.
                miss_vwrten <= 0;

                if (cbus_resp.last)
                    miss_state <= IDLE;

                if (cbus_resp.okay)
                    miss_pos.offset <= offset_t'(miss_pos.offset + 1);  // ensure overflow
            end

            default: /* do nothing */;
        endcase

        // write to victim buffer
        if (miss_vwrten) begin
            for (int i = 0; i < NUM_WORDS; i++) begin
                miss_victim[i] <= miss_voffset == offset_t'(i) ?
                    miss_rdata : miss_victim[i];
            end
        end

        // to miss stage
        if (req_to_miss) begin
            miss_state      <= READ;
            miss_addr       <= req_paddr;
            miss_pos.idx    <= req_victim_idx;
            miss_pos.index  <= req_iaddr.index;
            miss_pos.offset <= req_iaddr.offset;
            miss_ready      <= 0;
            // miss_vwrten     <= 0;
            miss_vrecord    <= ram_meta[req_victim_idx];
            miss_vtag       <= ram_tags[req_victim_idx];
        end
    end else begin
        hit_data_ok <= 0;
        miss_state  <= IDLE;
        miss_vwrten <= 0;
    end

    /**
     * DBus driver
     */
    assign dbus_resp.addr_ok = req_hit && req_miss_ready;
    assign dbus_resp.data_ok = hit_data_ok;
    assign dbus_resp.data    = hit_rdata;

    /**
     * CBus driver
     */
    assign cbus_req.valid    = miss_busy;
    assign cbus_req.is_write = miss_state == WRITE;
    assign cbus_req.addr     = miss_addr;
    assign cbus_req.order    = cbus_order_t'(OFFSET_BITS);
    assign cbus_req.wdata    = miss_victim[miss_pos.offset];

    /**
     * unused (for Verilator)
     */
    logic __unused_ok = &{1'b0,
        req_vaddr,
    1'b0};
endmodule