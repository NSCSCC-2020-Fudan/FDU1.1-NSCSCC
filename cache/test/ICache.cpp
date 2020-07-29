#include "ICache.h"

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH {
    top->reset(false);
    top->issue_read(4);
    top->tick(256);
    assert(top->inst->ibus_resp_x_addr_ok == 1);
    assert(top->inst->ibus_resp_x_data_ok == 1);
    assert(top->inst->ibus_resp_x_index == 1);
    assert(top->inst->ibus_resp_x_data == ((u64(remap(1)) << 32) | remap(0)));
} AS("single read");

WITH LOG {
    Pipeline p(top);
    p.expect32(123 * 4, remap(123));
    p.wait(256);
    p.expect(124);
    p.expect(126);
    p.expect64(122 * 4, remap(122, 123));
    p.wait(256);
    p.expect(122);
    p.expect(124);
    p.expect(126);
    p.wait(256);
} AS("on pipeline");

WITH {
    for (int addr = 0; addr < 8192; addr++) {
        top->issue_read(addr * 4);
        top->inst->ibus_req_x_req = 0;
        top->eval();
        for (int i = 0; i < 256; i++) {
            assert(top->inst->req_hit == 0);
            assert(top->inst->ibus_resp_x_data_ok == 0);
            top->tick();
        }
    }
} AS("fake read");

WITH {
    Pipeline p(top);
    for (int i = 0; i < MEMORY_SIZE; i += 2) {
        p.expect(i);
    }
    p.wait();
} AS("sequential read 1");

WITH {
    Pipeline p(top);
    for (int i = 1; i < MEMORY_SIZE; i += 2) {
        p.expect(i);
    }
    p.wait();
} AS("sequential read 2");

WITH SKIP {
    constexpr int T = 100000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int n = randu(1, 128);
        int addr = randu(0, MEMORY_SIZE - n - 1);
        for (int i = 0; i < n; i++) {
            p.expect(addr + i);
        }
        p.wait();
    }
} AS("random block read");

WITH SKIP {
    constexpr int T = 500000;

    Pipeline p(top);
    for (int i = 0; i < T; i++) {
        int addr = randu(0, MEMORY_SIZE - 1);
        p.expect(addr);
    }

    p.wait();
} AS("random read");

WITH {
    Pipeline p(top);
    for (int i = MEMORY_SIZE - 2; i >= 0; i -= 2) {
        p.expect(i);
    }
    p.wait();
} AS("backward read 1");

WITH {
    Pipeline p(top);
    for (int i = MEMORY_SIZE - 1; i >= 0; i -= 2) {
        p.expect(i);
    }
    p.wait();
} AS("backward read 2");