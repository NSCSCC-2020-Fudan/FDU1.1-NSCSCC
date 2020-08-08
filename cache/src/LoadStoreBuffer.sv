`include "defs.svh"
`include "data_bus.svh"

module LoadStoreBuffer #(
`ifdef IN_SIMULATION
    parameter int BUFFER_LENGTH = 4,
`else
    parameter int BUFFER_LENGTH = 16,
`endif

    parameter type req_t  = dbus_req_t,
    parameter type resp_t = dbus_resp_t,

    localparam int INDEX_BITS = $clog2(BUFFER_LENGTH),

    localparam type record_t = struct packed {
        logic avail;
    },

    localparam type index_t = logic    [INDEX_BITS    - 1:0],
    localparam type meta_t  = record_t [BUFFER_LENGTH - 1:0],
    localparam type fifo_t  = req_t    [BUFFER_LENGTH - 1:0]
) (
    input logic clk, resetn,

    input  req_t  m_req,
    output resp_t m_resp,
    output req_t  s_req,
    input  resp_t s_resp
);
    /**
     * states & storages
     */
    index_t head, tail;
    meta_t  meta;
    fifo_t  fifo;

    /**
     * FIFO signals
     */
    req_t tail_elem;
    logic fifo_avail;
    logic fifo_empty;
    logic fifo_ready;
    logic fifo_push;
    logic fifo_pop;

    assign tail_elem  = fifo[tail];
    assign fifo_avail = meta[head].avail;
    assign fifo_empty = meta[tail].avail;
    assign fifo_ready = fifo_avail && (fifo_empty || m_req.is_write == tail_elem.is_write);
    assign fifo_push  = m_req.req && fifo_ready;
    assign fifo_pop   = s_resp.data_ok;

    /**
     * state updates
     */
    logic last_data_ok;

    always_ff @(posedge clk)
    if (resetn) begin
        last_data_ok <= fifo_push && m_req.is_write;

        for (int i = 0; i < BUFFER_LENGTH; i++) begin
            /*unique*/ if (fifo_push && head == index_t'(i))
                meta[i].avail <= 0;
            else if (fifo_pop && tail == index_t'(i))
                meta[i].avail <= 1;
            else
                meta[i].avail <= meta[i].avail;
        end

        for (int i = 0; i < BUFFER_LENGTH; i++) begin
            /*unique*/ if (fifo_push && head == index_t'(i)) begin
                fifo[i]     <= m_req;
                fifo[i].req <= fifo_empty ? ~s_resp.addr_ok : 1;
            end else if (tail == index_t'(i) && s_resp.addr_ok) begin
                fifo[i]     <= fifo[i];
                fifo[i].req <= 0;
            end else
                fifo[i] <= fifo[i];
        end

        if (fifo_push)
            head <= index_t'(head + 1);
        if (fifo_pop)
            tail <= index_t'(tail + 1);
    end else begin
        last_data_ok <= 0;
        {head, tail} <= 0;
        meta <= '1;  // fill all ones
    end

    /**
     * driver for master
     */
    assign m_resp.data    = s_resp.data;
    assign m_resp.addr_ok = fifo_ready;
    assign m_resp.data_ok = tail_elem.is_write ? last_data_ok : s_resp.data_ok;

    assign s_req = fifo_empty ? m_req : tail_elem;
endmodule