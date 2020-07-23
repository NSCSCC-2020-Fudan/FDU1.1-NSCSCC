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
    p.wait();
    p.expect(124);
    p.expect(126);
    p.expect64(122 * 4, remap(122, 123));
    p.wait();
    p.expect(122);
    p.expect(124);
    p.expect(126);
    p.wait();
} AS("on pipeline");

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

/**
 * TODO:
 * * [ ] random block read
 * * [ ] random read
 * * [ ] fake read
 * * [ ] backward read
 */