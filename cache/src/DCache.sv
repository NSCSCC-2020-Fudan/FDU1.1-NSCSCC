`include "data_bus.svh"
`include "cache_bus.svh"

module DCache #(
`ifndef IN_SIMULATION
    // 4-way 16KB configuration:
    parameter int IDX_BITS    = 2,
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
    localparam type line_t = struct packed {
        logic valid;
        logic dirty;
        tag_t tag;
    },
    localparam type bundle_t = line_t [NUM_WAYS - 1:0],
    localparam type select_t = logic [NUM_WAYS - 2:0],
    localparam type set_t = struct packed {
        select_t select;
        bundle_t lines;
    }
) (
    input logic clk, resetn,

    input  addr_t      dbus_req_vaddr,
    input  dbus_req_t  dbus_req,
    output dbus_resp_t dbus_resp,
    output cbus_req_t  cbus_req,
    input  cbus_resp_t cbus_resp
);
    /**
     * process request addresses
     */
    addr_t req_vaddr, req_paddr;
    assign req_vaddr = dbus_req_vaddr;
    assign req_paddr = dbus_req.addr;

    // set info storage
`ifdef NO_VIVADO
    bundle_t [NUM_SETS - 1:0] set_lines;
    select_t [NUM_SETS - 1:0] set_select;
`else
    bundle_t set_lines[NUM_SETS - 1:0];
    select_t set_select[NUM_SETS - 1:0];
`endif

    set_t req_set;
    assign req_set.lines  = set_lines[req_vaddr.index];
    assign req_set.select = set_select[req_vaddr.index];

    // full associative search
    logic [NUM_WAYS - 1:0] req_hit_bits;
    logic req_hit;
    idx_t req_idx;

    assign req_hit = |req_hit_bits;
    for (genvar i = 0; i < NUM_WAYS; i++) begin
        assign req_hit_bits[i] = req_set.lines[i].valid &&
            req_paddr.tag == req_set.lines[i].tag;
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
        .select(req_set.select),
        .victim_idx(req_victim_idx),
        .idx(req_idx),
        .new_select(req_new_select)
    );

    // generate cache BRAM address
    iaddr_t req_iaddr;
    assign req_iaddr.idx    = req_idx;
    assign req_iaddr.index  = req_paddr.index;
    assign req_iaddr.offset = req_paddr.offset;

    // assignment later
    logic req_in_miss;
    logic req_miss_ready;
    logic req_ready;
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
    assign hit_write_en = req_to_hit ? dbus_req.write_en : 0;
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
    line_t   miss_vline;
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
    assign miss_is_dirty = miss_vline.valid && miss_vline.dirty;
    assign miss_avail    = miss_state == IDLE || (miss_state == WRITE && cbus_resp.last);
    assign miss_write_en = miss_state == READ && cbus_resp.okay ? BRAM_FULL_MASK : 0;
    assign miss_wdata    = cbus_resp.rdata;

    /**
     * determine whether the data is ready
     */
    assign req_in_miss = miss_busy &&
        req_iaddr.idx == miss_pos.idx &&
        req_iaddr.index == miss_pos.index;
    assign req_miss_ready = miss_ready[req_iaddr.offset];
    assign req_ready      = req_hit && (!req_in_miss || req_miss_ready);
    assign req_to_hit     = dbus_req.valid && req_ready;
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
     * state transitions
     */
    always_ff @(posedge clk)
    if (resetn) begin
        // to hit stage
        hit_data_ok <= req_to_hit;
        if (req_to_hit) begin
            for (int i = 0; i < NUM_SETS; i++) begin
                set_select[i] <= req_iaddr.index == index_t'(i) ?
                    req_new_select : set_select[i];
            end

            if (dbus_req.is_write) begin
                for (int i = 0; i < NUM_SETS; i++)
                if (req_iaddr.index == index_t'(i))
                for (int j = 0; j < NUM_WAYS; j++) begin
                    set_lines[i][j].dirty <= req_iaddr.idx == idx_t'(j) ?
                        1 : set_lines[i][j].dirty;
                    set_lines[i][j].valid <= set_lines[i][j].valid;
                    set_lines[i][j].tag   <= set_lines[i][j].tag;
                end
            end
        end

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
                    miss_addr.tag <= miss_vline.tag;
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
            miss_vline      <= set_lines[req_iaddr.index][req_victim_idx];

            for (int i = 0; i < NUM_SETS; i++)
            for (int j = 0; j < NUM_WAYS; j++) begin
                if (req_iaddr.index == index_t'(i) &&
                    req_victim_idx == idx_t'(j)) begin
                    set_lines[i][j].valid <= 1;
                    set_lines[i][j].dirty <= 0;
                    set_lines[i][j].tag   <= req_paddr.tag;
                end else begin
                    set_lines[i][j] <= set_lines[i][j];
                end
            end
        end
    end else begin
        hit_data_ok <= 0;
        miss_state  <= IDLE;
        miss_vwrten <= 0;

        for (int i = 0; i < NUM_SETS; i++) begin
            set_select[i] <= 0;

            for (int j = 0; j < NUM_WAYS; j++) begin
                set_lines[i][j].valid <= 0;
                set_lines[i][j].dirty <= 0;
            end
        end
    end

    /**
     * DBus driver
     */
    assign dbus_resp.addr_ok = req_ready;
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