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
        for (int i = 0; i < 64; i++) {
            assert(top->inst->req_hit == 0);
            assert(top->inst->ibus_resp_x_data_ok == 0);
            top->tick();
        }
    }
} AS("fake read");

WITH {
    top->issue_cop(0, 0, 0b111);
    assert(top->inst->ibus_resp_x_addr_ok == 1);
    top->inst->ibus_req_x_cache_op_x_req = 0;
    top->eval();
    assert(top->inst->ibus_resp_x_addr_ok == 0);
} AS("fake cop 1");

WITH {
    top->issue_cop(0, 0, 0b111);
    assert(top->inst->ibus_resp_x_addr_ok == 1);
    top->reset_req();
    assert(top->inst->ibus_resp_x_addr_ok == 0);
} AS("fake cop 2");

WITH LOG {
    Pipeline p(top);
    p.expect(0);
    p.wait(64);
    top->issue_read(0);
    assert(top->inst->ibus_resp_x_addr_ok == 1);
    top->reset_req();

    p.expect(0);
    p.cop(0, 0b010);
    p.wait(64);
    top->issue_read(0);
    assert(top->inst->ibus_resp_x_addr_ok == 0);
} AS("simple invalidate");

WITH {
    Pipeline p(top);
    auto fill = [&p] {
        for (int i = 0; i < 256; i++) {
            p.expect(i + 4096);
        }
        p.wait(8192);
        for (int i = 0; i < 256; i++) {
            top->issue_read(_i(i + 4096));
            assert(top->inst->ibus_resp_x_addr_ok == 1);
        }
        top->reset_req();
    };

    fill();
    for (int i = 0; i < 256; i++) {
        p.cop(_i(i + 4096), 0b010);
    }
    p.wait(8192);
    for (int i = 0; i < 256; i++) {
        top->issue_read(_i(i + 4096));
        assert(top->inst->ibus_resp_x_addr_ok == 0);
    }
    top->reset_req();

    fill();
    for (int i = 0; i < 8; i++)
    for (int j = 0; j < 4; j++) {
        p.cop((i << 7) | (j << 5), 0b110);
    }
    p.wait(8192);
    for (int i = 0; i < 256; i++) {
        top->issue_read(_i(i + 4096));
        assert(top->inst->ibus_resp_x_addr_ok == 0);
    }
    top->reset_req();
} AS("range invalidate");

WITH SKIP {
    constexpr int T = 500000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int i = randu(0, MEMORY_SIZE - 1);
        p.expect(i);
        p.wait(256);
        top->issue_read(_i(i));
        assert(top->inst->ibus_resp_x_addr_ok == 1);
        top->reset_req();
        p.cop(_i(i), 0b010);
        p.wait(256);
        top->issue_read(_i(i));
        assert(top->inst->ibus_resp_x_addr_ok == 0);
        top->reset_req();
    }
} AS("random invalidate");

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