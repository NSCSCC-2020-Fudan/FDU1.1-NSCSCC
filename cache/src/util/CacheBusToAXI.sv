`include "defs.svh"
`include "cache_bus.svh"
`include "axi.svh"

/**
 * interconnect with $bus & AXI.
 *
 * NOTE: assume the widths of $Bus & AXI are 32 bits.
 */
module CacheBusToAXI(
    input logic clk, reset,

    input  cbus_req_t  cbus_req,
    output cbus_resp_t cbus_resp,
    output axi_req_t   axi_req,
    input  axi_resp_t  axi_resp
);
    localparam axi_burst_size AXI_BURST_SIZE =
        axi_burst_size'($clog2(CBUS_DATA_WIDTH));

    localparam int EXCEED_BITS = CBUS_LEN_BITS - AXI_LEN_BITS;
    `ASSERT(EXCEED_BITS > 0,
        "CBUS_LEN_BITS muse be larger than AXI_LEN_BITS.");

    typedef logic [EXCEED_BITS - 1:0] round_t;

    // calculate the minimal number of AXI transactions and
    // determine the length of each transaction.
    //
    // variables prefiexed with "actual_" are the real value,
    // otherwise the value minus one, since they are intended
    // to be initial values of counters.
    round_t    num_round;
    cbus_len_t actual_len,  len;
    axi_len_t  axi_len;
    addr_t     addr_stride;
    assign actual_len = 1 << cbus_req.order;
    assign len = actual_len - 1;
    assign num_round = actual_len[CBUS_LEN_BITS - 1:AXI_LEN_BITS];
    assign axi_len = (|num_round) ? AXI_MAXLEN_VALUE : actual_len[AXI_LEN_BITS - 1:0];

    // NOTE: assume 32 bit data channel.
    typedef logic [29:0] _u30_t;
    assign addr_stride = {_u30_t'(axi_len) + 30'b1, 2'b00};

    // NOTE: axready may be asserted even if axvalid is deasserted.
    logic addr_ok;
    assign addr_ok = cbus_req.valid && (axi_resp.aw.ready || axi_resp.ar.ready);
    assign cbus_resp.okay =
        (axi_req.w.valid && axi_resp.w.ready) ||
        (axi_req.r.ready && axi_resp.r.valid);

    enum logic [1:0] {
        INITIAL, TRANSFER, REQUEST, RESERVED
    } state;
    addr_t     current_addr;
    round_t    round_cnt;
    cbus_len_t len_cnt;

    logic is_last;
    assign is_last = round_cnt == 0 && len_cnt == 0;
    assign cbus_resp.last = state != INITIAL && is_last;

    // AXI driver
    always_comb begin
        axi_req = 0;
        unique case (state)
            INITIAL: if (cbus_req.valid) begin
                if (cbus_req.is_write) begin
                    axi_req.aw.valid = 1;
                    axi_req.aw.addr  = cbus_req.addr;
                    axi_req.aw.len   = axi_len;
                    axi_req.aw.size  = AXI_BURST_SIZE;
                    axi_req.aw.burst = BURST_INCR;
                    axi_req.aw.lock  = LOCK_NORMAL;
                    axi_req.aw.cache = MEM_DEFAULT;
                    axi_req.aw.prot  = 0;
                end else begin
                    axi_req.ar.valid = 1;
                    axi_req.ar.addr  = cbus_req.addr;
                    axi_req.ar.len   = axi_len;
                    axi_req.ar.size  = AXI_BURST_SIZE;
                    axi_req.ar.burst = BURST_INCR;
                    axi_req.ar.lock  = LOCK_NORMAL;
                    axi_req.ar.cache = MEM_DEFAULT;
                    axi_req.ar.prot  = 0;
                end
            end

            TRANSFER: begin
                if (cbus_req.is_write) begin
                    axi_req.w.valid = 1;
                    axi_req.w.data  = cbus_req.wdata;
                    axi_req.w.strb  = AXI_FULL_STROBE;
                    axi_req.w.last  = is_last;
                    axi_req.b.ready = 1;
                end else begin
                    axi_req.r.ready = 1;
                end
            end

            REQUEST: begin
                if (cbus_req.is_write) begin
                    axi_req.aw.valid = 1;
                    axi_req.aw.addr  = current_addr;
                    axi_req.aw.len   = axi_len;
                    axi_req.aw.size  = AXI_BURST_SIZE;
                    axi_req.aw.burst = BURST_INCR;
                    axi_req.aw.lock  = LOCK_NORMAL;
                    axi_req.aw.cache = MEM_DEFAULT;
                    axi_req.aw.prot  = 0;
                end else begin
                    axi_req.ar.valid = 1;
                    axi_req.ar.addr  = cbus_req.addr;
                    axi_req.ar.len   = axi_len;
                    axi_req.ar.size  = AXI_BURST_SIZE;
                    axi_req.ar.burst = BURST_INCR;
                    axi_req.ar.lock  = LOCK_NORMAL;
                    axi_req.ar.cache = MEM_DEFAULT;
                    axi_req.ar.prot  = 0;
                end
            end

            RESERVED: /* do nothing */;
        endcase
    end

    // read AXI response
    assign cbus_resp.rdata = axi_resp.r.data;

    // the FSM
    always_ff @(posedge clk)
    if (reset) begin
        state <= INITIAL;
        {current_addr, round_cnt, len_cnt} <= 0;
    end else begin
        unique case (state)
            INITIAL: if (addr_ok) begin
                state        <= TRANSFER;
                current_addr <= cbus_req.addr;
                round_cnt    <= num_round;
                len_cnt      <= len;
            end

            TRANSFER: if (is_last) begin
                state <= INITIAL;
            end else begin
                state        <= REQUEST;
                current_addr <= current_addr + addr_stride;
            end

            REQUEST: if (addr_ok) begin
                state     <= TRANSFER;
                round_cnt <= round_cnt - 1;
                len_cnt   <= len;
            end

            RESERVED: /* do nothing */;
        endcase
    end

    logic _unused_ok = &{1'b0, axi_resp, 1'b0};
endmodule