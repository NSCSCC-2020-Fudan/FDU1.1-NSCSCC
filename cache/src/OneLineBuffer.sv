`include "defs.svh"
`include "sramx.svh"
`include "cache_bus.svh"

module OneLineBuffer #(
    parameter int BUFFER_LENGTH = 16,

    localparam int BUFFER_SIZE  = 16 * BYTES_PER_WORD,      // 64
    localparam int BUFFER_ORDER = $clog2(BUFFER_LENGTH),    // 4
    localparam int ALIGN_BITS   = $clog2(BYTES_PER_WORD),   // 2
    localparam int OFFSET_BITS  = $clog2(BUFFER_LENGTH),    // 4
    localparam int TAG_BITS     = BITS_PER_WORD - OFFSET_BITS - ALIGN_BITS,  // 24

    localparam type align_t     = logic [ALIGN_BITS - 1:0],
    localparam type offset_t    = logic [OFFSET_BITS - 1:0],
    localparam type tag_t       = logic [TAG_BITS - 1:0],
    localparam type line_addr_t = struct packed {
        tag_t    tag;
        offset_t offset;
        align_t  index;
    }
) (
    input logic clk, resetn,

    input  sramx_req_t  sramx_req,
    output sramx_resp_t sramx_resp,
    output cbus_req_t   cbus_req,
    input  cbus_resp_t  cbus_resp
);
    typedef union packed {
        byte_t [BYTES_PER_WORD - 1:0] bytes;
        word_t                        word;
    } view_t;
    typedef view_t [BUFFER_LENGTH - 1:0] mem_t;
    typedef logic [BYTES_PER_WORD - 1:0] strobe_t;

    typedef enum logic [1:0] {
        IDLE, READ, WRITE, RESERVED
    } state_t;

    // state variables & storage
    logic       valid, dirty;
    tag_t       tag;
    mem_t       mem;
    sramx_req_t saved_req;
    state_t     state;
    offset_t    offset;

    // request parsing
    logic       tag_hit,  offset_hit;
    line_addr_t req_addr, saved_addr;
    strobe_t    req_strb, saved_strb;

    assign req_addr   = sramx_req.addr;
    assign saved_addr = saved_req.addr;
    assign tag_hit    = valid && tag == req_addr.tag;
    assign offset_hit = offset == saved_addr.offset;

    StrobeTranslator _req_strb_inst(
        .size(sramx_req.size),
        .offset(req_addr.index),
        .strobe(req_strb)
    );
    StrobeTranslator _saved_strb_inst(
        .size(saved_req.size),
        .offset(saved_addr.index),
        .strobe(saved_strb)
    );

    // the FSM
    always_ff @(posedge clk)
    if (resetn) begin
        unique case (state)
            IDLE: if (sramx_req.req) begin
                if (tag_hit) begin
                    if (sramx_req.wr) begin
                        dirty <= 1;
                        for (int i = 0; i < BUFFER_LENGTH; i++) begin
                            if (req_addr.offset == offset_t'(i)) begin
                                for (int j = 0; j < BYTES_PER_WORD; j++) begin
                                    mem[i].bytes[j] <= req_strb[j] ?
                                        sramx_req.wdata.bytes[j] :
                                        mem[i].bytes[j];
                                end
                            end
                        end
                    end
                end else begin
                    saved_req <= sramx_req;

                    if (dirty) begin
                        state  <= WRITE;
                        offset <= 0;
                    end else begin
                        state  <= READ;
                        offset <= req_addr.offset;
                    end
                end
            end

            READ: begin
                state <= cbus_resp.last ? IDLE : READ;

                if (cbus_resp.okay) begin
                    if (saved_req.wr && offset_hit) begin
                        // direct overwrite
                        for (int i = 0; i < BUFFER_LENGTH; i++) begin
                            if (offset == offset_t'(i)) begin
                                for (int j = 0; j < BYTES_PER_WORD; j++) begin
                                    mem[i].bytes[j] <=saved_strb[j] ?
                                        saved_req.wdata.bytes[j] :
                                        cbus_resp.rdata.bytes[j];
                                end
                            end
                        end
                    end else begin
                        for (int i = 0; i < BUFFER_LENGTH; i++) begin
                            mem[i] <= offset == offset_t'(i) ?
                                cbus_resp.rdata : mem[i];
                        end
                    end
                end

                // NOTE: be careful about offset overflow
                if (cbus_resp.okay)
                    offset <= offset + 1;

                // update meta info
                if (cbus_resp.last) begin
                    dirty <= saved_req.wr;
                    valid <= 1;
                    tag   <= saved_addr.tag;
                end
            end

            WRITE: begin
                state <= cbus_resp.last ? READ : WRITE;

                // NOTE: be careful about offset overflow
                if (cbus_resp.last)
                    offset <= saved_addr.offset;
                else if (cbus_resp.okay)
                    offset <= offset + 1;
            end

            RESERVED: /* do nothing */;
        endcase
    end else begin
        {valid, dirty} <= 0;
        state <= IDLE;
    end

    // SRAMx driver
    assign sramx_resp.addr_ok = state == IDLE;
    assign sramx_resp.data_ok =
        (state == IDLE && sramx_req.req && tag_hit) ||
        (state == READ && cbus_resp.okay && offset_hit);
    assign sramx_resp.rdata = state == IDLE ?
        mem[req_addr.offset] : cbus_resp.rdata;  // direct forwarding

    // $Bus driver
    assign cbus_req.valid    = state != IDLE;
    assign cbus_req.is_write = state == WRITE;
    assign cbus_req.order    = cbus_order_t'(BUFFER_ORDER);
    assign cbus_req.wdata    = mem[offset];
    assign cbus_req.addr     = {
        (state == WRITE ?
            {tag, {OFFSET_BITS{1'b0}}} :
            {saved_addr.tag, saved_addr.offset}
        ),
        {ALIGN_BITS{1'b0}}
    };

    logic __unused_ok = &{1'b0, saved_req, 1'b0};
endmodule