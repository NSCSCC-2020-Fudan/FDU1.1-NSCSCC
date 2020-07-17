#include "OneLineBuffer.h"

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH {
    top->issue_read(2, 4 * 31);

    int count = 0;
    while (!top->inst->sramx_resp_x_data_ok) {
        top->tick();
        top->print_cache();
        count++;
        assert(count < 256);
    }

    assert(top->inst->sramx_resp_x_rdata == 31);
} AS("single read");

WITH {
    for (int i = 0; i < 256; i++) {
        top->tick();
        top->issue_read(2, 4 * i);

        int count = 0;
        while (!top->inst->sramx_resp_x_addr_ok) {
            top->tick();
            count++;
            assert(count < 100);
        }

        if (!top->inst->sramx_resp_x_data_ok) {
            top->tick();
            top->inst->sramx_req_x_req = 0;
            top->inst->eval();
            while (!top->inst->sramx_resp_x_data_ok) {
                top->tick();
                count++;
                assert(count < 100);
            }
        }

        info("%x ?= %x\n", top->inst->sramx_resp_x_rdata, i);
        assert(top->inst->sramx_resp_x_rdata == i);
    }
} AS("sequential read");

WITH {
    top->issue_write(2, 4 * 7, 0xdeadbeef);

    int count = 0;
    while (!top->inst->sramx_resp_x_data_ok) {
        top->tick();
        top->print_cache();
        count++;
        assert(count < 256);
    }

    top->tick();  // handshake at posedge

    for (int i = 0; i < 8; i++) {
        if (i == 7)
            assert(top->inst->mem[i] == 0xdeadbeef);
        else
            assert(top->inst->mem[i] == i);
    }

    assert(top->cmem->mem[7] != 0xdeadbeef);
    assert(top->cmem->mem[7] == 7);
} AS("single write");

WITH LOG TRACE {
    u32 data[256];

    top->tick();
    for (int i = 0; i < 256; i++) {
        data[i] = randu();

        top->issue_write(2, 4 * i, data[i]);

        int count = 0;
        while (!top->inst->sramx_resp_x_addr_ok) {
            top->tick();
            assert(++count < 256);
        }

        bool data_ok = top->inst->sramx_resp_x_data_ok;
        top->tick();
        top->inst->sramx_req_x_req = 0;
        top->inst->eval();

        if (!data_ok) {
            do {
                top->tick();
                assert(++count < 256);
            } while (!top->inst->sramx_resp_x_data_ok);
            top->tick();
        }

        top->issue_read(2, 4 * i);

        count = 0;
        while (!top->inst->sramx_resp_x_addr_ok) {
            top->tick();
            assert(++count < 256);
        }

        if (!top->inst->sramx_resp_x_data_ok) {
            top->tick();
            top->inst->sramx_req_x_req = 0;
            top->inst->eval();

            while (!top->inst->sramx_resp_x_data_ok) {
                top->tick();
                count++;
                assert(count < 100);
            }
        }

        u32 rdata = top->inst->sramx_resp_x_rdata;
        top->tick();

        info("data[%d] = %08x, rdata = %08x\n", i, data[i], rdata);
        assert(rdata == data[i]);
    }

    // force writing back
    top->issue_read(2, 0);
    top->tick(256);

    for (int i = 0; i < 256; i++) {
        info("data[%d] = %08x, mem[%d] = %08x\n", i, data[i], i, top->cmem->mem[i]);
        assert(data[i] == top->cmem->mem[i]);
    }
} AS("sequential write");