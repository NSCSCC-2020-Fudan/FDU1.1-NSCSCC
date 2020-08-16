`include "defs.svh"
`include "cache_bus.svh"
`include "axi.svh"

/**
 * interconnect with $bus & AXI.
 *
 * NOTE: assume the widths of $Bus & AXI are 32 bits.
 */
module CacheBusToAXI #(
    parameter `STRING AXI_MODE = "wrap"  // "wrap" or "incr"
) (
    input logic clk, resetn,

    input  cbus_req_t  cbus_req,
    output cbus_resp_t cbus_resp,
    output axi_req_t   axi_req,
    input  axi_resp_t  axi_resp
);
    localparam axi_burst_size AXI_BURST_SIZE =
        axi_burst_size'($clog2(CBUS_DATA_BYTES));
    localparam axi_burst_type AXI_BURST_TYPE =
        AXI_MODE == "wrap" ? BURST_WRAP : BURST_INCR;

    localparam int EXCEED_BITS = CBUS_LEN_BITS - AXI_LEN_BITS;
    `ASSERT(EXCEED_BITS > 0,
        "CBUS_LEN_BITS muse be larger than AXI_LEN_BITS.");


    typedef logic [EXCEED_BITS - 1:0] round_t;

    // calculate the minimal number of AXI transactions and
    // determine the length of each transaction.
    //
    // both `axi_len` and `num_round` are used as intial values
    // of counters. They differ from their actual value by one.
    axi_len_t axi_len;
    round_t   num_round;
    assign {num_round, axi_len} = (1 << cbus_req.order) - 1;

    // NOTE: assume 32 bit data channel.
    addr_t addr_step;
    typedef logic [29:0] _u30_t;
    assign addr_step = {_u30_t'(axi_len) + 30'b1, 2'b00};

    // NOTE: axready may be asserted even if axvalid is deasserted.
    // `transaction_ok`: DO RESPECT THE B CHANNEL! QAQ
    logic addr_ok, transaction_ok;
    assign addr_ok        = cbus_req.is_write ? axi_resp.aw.ready : axi_resp.ar.ready;
    // assign transaction_ok = axi_req.b.ready && axi_resp.b.valid;
    assign transaction_ok = axi_resp.b.valid;

    // state variables
    enum logic [1:0] {
        IDLE, TRANSFER, REQUEST, WAITING
    } state;
    addr_t    current_addr;
    round_t   round_cnt;
    axi_len_t len_cnt;

    // detect completion
    logic is_last, is_final;
    assign is_last  = len_cnt == 0;
    assign is_final = is_last && round_cnt == 0;

    // since we never issue both AR & AW request in one clock cycle,
    // it's okay to ignore `cbus_req.is_write`.
    // the last write `okay` response is replaced by the end of transaction.
    logic rw_handshake;
    // assign rw_handshake =
    //     (axi_req.w.valid && axi_resp.w.ready) ||
    //     (axi_req.r.ready && axi_resp.r.valid);
    assign rw_handshake = axi_resp.w.ready || axi_resp.r.valid;
    assign cbus_resp.okay = (cbus_req.is_write && is_last) ?
        transaction_ok : rw_handshake;

    // only in WAITING state, `transaction_ok` will be asserted.
    assign cbus_resp.last = is_final &&
        (cbus_req.is_write ? transaction_ok : rw_handshake);

    // AXI driver
    `define APPLY_AXI_DEFAULTS(channel) \
        axi_req.channel.size  = AXI_BURST_SIZE; \
        axi_req.channel.burst = AXI_BURST_TYPE; \
        axi_req.channel.lock  = LOCK_NORMAL; \
        axi_req.channel.cache = MEM_DEFAULT; \
        axi_req.channel.prot  = 0;

    always_comb begin
        axi_req = 0;

        // "verilator" updated to 4.036, which doesn't accept unique0
        unique case (state)
            IDLE: if (cbus_req.valid) begin
                if (cbus_req.is_write) begin
                    axi_req.aw.valid = 1;
                    axi_req.aw.addr  = cbus_req.addr;
                    axi_req.aw.len   = axi_len;
                    `APPLY_AXI_DEFAULTS(aw);
                end else begin
                    axi_req.ar.valid = 1;
                    axi_req.ar.addr  = cbus_req.addr;
                    axi_req.ar.len   = axi_len;
                    `APPLY_AXI_DEFAULTS(ar);
                end
            end

            TRANSFER: begin
                if (cbus_req.is_write) begin
                    axi_req.w.valid = 1;
                    axi_req.w.data  = cbus_req.wdata;
                    axi_req.w.strb  = AXI_FULL_STROBE;
                    axi_req.w.last  = is_last;
                end else begin
                    axi_req.r.ready = 1;
                end
            end

            REQUEST: begin
                if (cbus_req.is_write) begin
                    axi_req.aw.valid = 1;
                    axi_req.aw.addr  = current_addr;
                    axi_req.aw.len   = axi_len;
                    `APPLY_AXI_DEFAULTS(aw);
                end else begin
                    axi_req.ar.valid = 1;
                    axi_req.ar.addr  = current_addr;
                    axi_req.ar.len   = axi_len;
                    `APPLY_AXI_DEFAULTS(ar);
                end
            end

            WAITING: begin
                axi_req.b.ready = 1;
            end
        endcase
    end

    // read AXI response
    assign cbus_resp.rdata = axi_resp.r.data;

    // the FSM
    always_ff @(posedge clk)
    if (resetn) begin
        unique case (state)
            IDLE: if (cbus_req.valid && addr_ok) begin
                state        <= TRANSFER;
                current_addr <= cbus_req.addr;
                round_cnt    <= num_round;
                len_cnt      <= axi_len;
            end

            TRANSFER: if (rw_handshake) begin
                if (is_final) begin
                    state <= cbus_req.is_write ? WAITING : IDLE;
                end else if (is_last) begin
                    state        <= cbus_req.is_write ? WAITING : REQUEST;
                    current_addr <= current_addr + addr_step;
                end else begin
                    len_cnt <= len_cnt - 1;
                end
            end

            REQUEST: if (addr_ok) begin
                state     <= TRANSFER;
                round_cnt <= round_cnt - 1;
                len_cnt   <= axi_len;
            end

            WAITING: if (transaction_ok) begin
                state <= is_final ? IDLE : REQUEST;
            end
        endcase
    end else begin
        state <= IDLE;
        {current_addr, round_cnt, len_cnt} <= 0;
    end

    logic _unused_ok = &{1'b0, axi_resp, 1'b0};
endmodule