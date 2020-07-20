#include "OneLineBuffer.h"

static auto top = new Top;

auto fetch(int max_count = 256) -> u32 {
    int count = 0;
    while (!top->inst->sramx_resp_x_addr_ok) {
        top->tick();
        assert(++count < max_count);
    }

    if (!top->inst->sramx_resp_x_data_ok) {
        top->tick();
        top->inst->sramx_req_x_req = 0;
        top->inst->eval();

        while (!top->inst->sramx_resp_x_data_ok) {
            top->tick();
            assert(++count < max_count);
        }
    }

    u32 rdata = top->inst->sramx_resp_x_rdata;
    top->tick();

    return rdata;
}

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
        u32 rdata = fetch();
        info("%x ?= %x\n", rdata, i);
        assert(rdata == i);
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
    top->tick(256);

    for (int i = 0; i < 8; i++) {
        if (i == 7)
            assert(top->inst->mem[i] == 0xdeadbeef);
        else
            assert(top->inst->mem[i] == i);
    }

    assert(top->cmem->mem[7] != 0xdeadbeef);
    assert(top->cmem->mem[7] == 7);
} AS("single write");

WITH {
    u32 data[256];

    top->tick();
    for (int i = 0; i < 256; i++) {
        data[i] = randu();

        top->issue_write(2, 4 * i, data[i]);
        fetch();
        top->issue_read(2, 4 * i);
        u32 rdata = fetch();
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

WITH SKIP {
    constexpr int OP_COUNT = 500000;

    enum OpType : int {
        READ, WRITE
    };

    u32 ref_mem[256];
    for (int i = 0; i < 256; i++) {
        ref_mem[i] = i;
    }

    top->tick(8);
    for (int _t = 0; _t < OP_COUNT; _t++) {
        int op = randu(0, 1);
        int index = randu(0, 255);
        int addr = index * 4;
        u32 data = randu();

        switch (op) {
            case READ: {
                info("test: read @0x%x[%d]\n", addr, index);
                top->issue_read(2, addr);
                u32 rdata = fetch();
                top->tick();
                info("ref_mem[%d] = %08x, rdata = %08x\n", index, ref_mem[index], rdata);
                assert(ref_mem[index] == rdata);
            } break;

            case WRITE: {
                info("test: write @0x%x[%d]: %08x\n", addr, index, data);
                ref_mem[index] = data;
                top->issue_write(2, addr, data);
                fetch();
                top->tick();
            } break;
        };
    }

    // force writing back
    top->issue_read(2, 0);
    top->tick(256);
    top->issue_read(2, 256);
    top->tick(256);

    for (int i = 0; i < 256; i++) {
        info("ref_mem[%d] = %08x, mem[%d] = %08x\n", i, ref_mem[i], i, top->cmem->mem[i]);
        assert(ref_mem[i] == top->cmem->mem[i]);
    }
} AS("random read/write");

WITH {
    top->issue_write(1, 2, 0x0000cccc);
    top->tick(256);
    top->issue_read(1, 2);
    assert(top->inst->sramx_resp_x_rdata == 0x00000000);
    top->tick();
    top->issue_write(1, 2, 0xcccccccc);
    top->tick();
    top->issue_read(1, 0);
    assert(top->inst->sramx_resp_x_rdata == 0xcccc0000);
    top->tick();
    top->issue_write(0, 0, 0x12345678);
    top->tick();
    top->issue_write(0, 1, 0x87654321);
    top->tick();
    top->issue_read(2, 0);
    assert(top->inst->sramx_resp_x_rdata == 0xcccc4378);
} AS("partial write");

WITH {
    u32 mem_cpy[16];
    memcpy(mem_cpy, top->inst->mem, sizeof(mem_cpy));

    top->issue_read(2, 0);
    top->inst->sramx_req_x_req = 0;  // fake it
    top->inst->eval();

    top->tick(256);

    assert(top->inst->sramx_resp_x_addr_ok == true);
    assert(top->inst->sramx_resp_x_data_ok == false);
    assert(top->inst->valid == 0);
    assert(top->inst->dirty == 0);
    for (int i = 0; i < 16; i++) {
        assert(top->inst->mem[i] == mem_cpy[i]);
    }
} AS("fake request 1");

WITH {
    top->issue_read(2, 0);
    top->tick(256);
    top->inst->sramx_req_x_req = 0;
    top->tick();

    top->issue_write(2, 4, 0xcccccccc);
    top->inst->sramx_req_x_req = 0;  // fake it
    top->inst->eval();
    assert(top->inst->sramx_resp_x_data_ok == false);

    top->tick(2);

    for (int i = 0; i < 16; i++) {
        info("mem[%d] = %08x\n", i, top->inst->mem[i]);
        assert(top->inst->mem[i] == i);
    }
} AS("fake request 2");