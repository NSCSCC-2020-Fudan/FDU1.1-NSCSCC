#include "DCache.h"

#include <numeric>

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH LOG {
    Pipeline p(top);
    p.expect(_i(7), 7);
    p.write(_i(4), 0x12345678, 0b1101);
    p.expect(_i(6), 6);
    p.expect(_i(4), 0x12340078);
    p.expect(_i(1), 1);
    p.expect(_i(4), 0x12340078);
    p.wait(32);
} AS("test pipeline");

WITH {
    for (int addr = 0; addr < 8192; addr++) {
        top->issue_read(_i(addr));
        top->reset_req();
        top->eval();

        for (int i = 0; i < 128; i++) {
            assert(top->inst->req_hit == 0);
            assert(top->inst->dbus_resp_x_data_ok == 0);
            top->tick();
        }
    }
} AS("fake read");

WITH {
    for (int addr = 0; addr < 8192; addr++) {
        top->issue_write(_i(addr), randu());
        top->reset_req();
        top->eval();

        for (int i = 0; i < 128; i++) {
            assert(top->inst->req_hit == 0);
            assert(top->inst->dbus_resp_x_data_ok == 0);
            top->tick();
        }
    }
} AS("fake write");

WITH {
    top->issue_cop(0, 0, 0b010);
    assert(top->inst->dbus_resp_x_addr_ok == 1);
    top->inst->dbus_req_x_cache_op_x_req = 0;
    top->eval();
    assert(top->inst->dbus_resp_x_addr_ok == 0);
} AS("fake cop 1");

WITH {
    top->issue_cop(0, 0, 0b010);
    assert(top->inst->dbus_resp_x_addr_ok == 1);
    top->reset_req();
    assert(top->inst->dbus_resp_x_addr_ok == 0);
} AS("fake cop 2");

WITH {
    Pipeline p(top);
    p.write(0, 0x12345678, 0b1111, 0);
    p.write(0x110, 0x87654321, 0b1111, 0x10);
    p.cop(0, 0b001, 0);
    p.cop(0x110, 0b001, 0x10);
    p.tick(512);
    assert(top->cmem->mem[0] == 0x12345678);
    assert(top->cmem->mem[0x110 >> 2] == 0x87654321);
} AS("physical addr");

WITH {
    Pipeline p(top);
    for (int i = 0; i < 65536; i++) {
        p.expect(_i(i), i);
    }
    p.wait();
} AS("naïve sequential read");

WITH LOG {
    Pipeline p(top);
    p.expect(0, 0);
    // p.cop(0, 0b010);
    p.wait(64);
    top->issue_read(0);
    assert(top->inst->dbus_resp_x_addr_ok == 1);
    top->reset_req();

    p.expect(0, 0);
    p.cop(0, 0b010);
    p.wait(64);
    top->issue_read(0);
    assert(top->inst->dbus_resp_x_addr_ok == 0);
} AS("simple invalidate");

WITH {
    Pipeline p(top);
    auto fill = [&p] {
        for (int i = 0; i < 128; i++) {
            p.expect(_i(i), i);
        }
        p.wait(8192);
        for (int i = 0; i < 128; i++) {
            top->issue_read(_i(i));
            assert(top->inst->dbus_resp_x_addr_ok == 1);
        }
        top->reset_req();
    };

    fill();
    for (int i = 0; i < 128; i++) {
        p.cop(_i(i), 0b010);
    }
    p.wait(8192);
    for (int i = 0; i < 128; i++) {
        top->issue_read(_i(i));
        assert(top->inst->dbus_resp_x_addr_ok == 0);
    }
    top->reset_req();

    fill();
    for (int i = 0; i < 8; i++)
    for (int j = 0; j < 4; j++) {
        p.cop((i << 6) | (j << 4), 0b110);
    }
    p.wait(8192);
    for (int i = 0; i < 128; i++) {
        top->issue_read(_i(i));
        assert(top->inst->dbus_resp_x_addr_ok == 0);
    }
    top->reset_req();
} AS("range invalidate");

WITH SKIP {
    constexpr int T = 500000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int i = randu(0, MEMORY_SIZE - 1);
        p.expect(_i(i), i);
        p.wait(256);
        top->issue_read(_i(i));
        assert(top->inst->dbus_resp_x_addr_ok == 1);
        top->reset_req();
        p.cop(_i(i), 0b010);
        p.wait(256);
        top->issue_read(_i(i));
        assert(top->inst->dbus_resp_x_addr_ok == 0);
        top->reset_req();
    }
} AS("random invalidate");

WITH LOG {
    Pipeline p(top);

    p.write(0, 0x19260817, 0b1111);
    p.cop(0, 0b001);
    p.tick(256);
    assert(top->cmem->mem[0] == 0x19260817);

    p.write(48, 0xabcd4321, 0b1111);
    p.wait(256);
    top->issue_cop(48, 48, 0b001);
    assert(top->inst->dbus_resp_x_addr_ok == 0);
    top->reset_req();
    p.cop(48, 0b001);
    p.tick(256);
    assert(top->cmem->mem[12] == 0xabcd4321);

    // test dirty flag
    top->cmem->mem[12] = 0;
    p.cop(48, 0b001);
    p.tick(256);
    assert(top->cmem->mem[12] == 0);
} AS("simple writeback");

WITH SKIP {
    constexpr int T = 100000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int i = randu(0, MEMORY_SIZE - 1);
        u32 data = randu();
        p.write(_i(i), data, 0b1111);
        p.cop(_i(i), 0b001);
        p.tick(64);
        assert(top->cmem->mem[i] == data);
    }
} AS("random writeback");

WITH LOG {
    Pipeline p(top);
    p.write(4, 0xabcdef12, 0b1111);
    p.cop(4, 0b011);
    p.tick(256);
    assert(top->cmem->mem[1] == 0xabcdef12);
    top->issue_read(0);
    assert(top->inst->dbus_resp_x_addr_ok == 0);
} AS("invalidate and writeback");

WITH SKIP {
    Pipeline p(top);
    for (int i = 0; i < MEMORY_SIZE; i++) {
        p.expect(_i(i), i);
    }
    p.wait();
} AS("sequential read");

WITH SKIP {
    Pipeline p(top);
    for (int i = 0; i < MEMORY_SIZE; i++) {
        p.write(_i(i), 0xcccccccc, 0b1111);
    }
    for (int i = 0; i < MEMORY_SIZE; i++) {
        p.expect(_i(i), 0xcccccccc);
    }
    p.wait();
} AS("memset");

WITH SKIP {
    u32 buf[32];
    Pipeline p(top);

    constexpr int MID = MEMORY_SIZE / 2;
    for (int i = 0; i < MID; i += 32) {
        for (int j = 0; j < 32; j++) {
            p.read(_i(MID + i + j), buf + j);
        }
        p.wait();
        for (int j = 0; j < 32; j++) {
            p.write(_i(i + j), buf[j], 0b1111);
        }
    }

    p.wait();

    for (int i = 0; i < MID; i++) {
        p.expect(_i(i), MID + i);
    }

    p.wait();
} AS("memcpy");

WITH SKIP {
    Pipeline p(top);
    for (int i = 0; i < MEMORY_SIZE; i++) {
        u32 v = randu();
        p.write(_i(i), v, 0b1111);
        p.expect(_i(i), v);
    }
    p.wait();
} AS("read/write repeat");

WITH SKIP {
    Pipeline p(top);
    for (int i = 0; i < MEMORY_SIZE; i++) {
        int op = randu(0, 1);
        u32 v = randu();
        if (op == 0)
            p.write(_i(i), v, 0b1111);
        else
            p.expect(_i(i), i);
    }
    p.wait();
} AS("read/write interleave");

WITH SKIP {
    Pipeline p(top);
    for (int i = MEMORY_SIZE - 1; i >= 0; i--) {
        p.expect(_i(i), i);
    }
    p.wait();
} AS("backward read");

WITH SKIP {
    Pipeline p(top);
    for (int i = MEMORY_SIZE - 1; i >= 0; i--) {
        p.write(_i(i), 0xcccccccc, 0b1111);
    }
    for (int i = MEMORY_SIZE - 1; i >= 0; i--) {
        p.expect(_i(i), 0xcccccccc);
    }
    p.wait();
} AS("backward memset");

WITH SKIP {
    std::vector<u32> ref;
    ref.resize(MEMORY_SIZE);
    std::iota(ref.begin(), ref.end(), 0);

    constexpr int T = 500000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int n = randu(1, 128);
        int s = randu(0, MEMORY_SIZE - n);
        int t = randu(0, 1);

        info("n = %d, s = %d\n", n, s);
        if (t == 0) {
            info("write");
            for (int i = 0; i < n; i++) {
                u32 v = randu();
                ref[s + i] = v;
                p.write(_i(s + i), v, 0b1111);
            }
        } else {
            info("read");
            for (int i = 0; i < n; i++) {
                p.expect(_i(s + i), ref[s + i]);
            }
        }
    }

    p.wait();
} AS("random block read/write");

WITH SKIP {
    std::vector<u32> ref;
    ref.resize(MEMORY_SIZE);
    std::iota(ref.begin(), ref.end(), 0);

    constexpr int T = 2000000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int addr = randu(0, MEMORY_SIZE - 1);
        int op = randu(1, 9);

        if (2 <= op && op <= 5) {
            u32 v = randu();
            ref[addr] = v;
            p.write(_i(addr), v, 0b1111);
        }
        if (6 <= op && op <= 9) {
            p.expect(_i(addr), ref[addr]);
        }
        if (op == 1) {
            p.wait();
        }
    }

    p.wait();
} AS("random read/write");

WITH SKIP {
    std::vector<u32> ref;
    ref.resize(MEMORY_SIZE);
    std::iota(ref.begin(), ref.end(), 0);

    constexpr int T = 2000000;

    Pipeline p(top);
    for (int _t = 0; _t < T; _t++) {
        int addr = randu(0, MEMORY_SIZE - 1);
        int op = randu(1, 9);

        if (2 <= op && op <= 5) {
            u32 v = randu();
            ref[addr] = v;
            p.write(_i(addr), v, 0b1111);
        }
        if (6 <= op && op <= 9) {
            p.expect(_i(addr), ref[addr]);
        }
        if (op == 1) {
            p.wait();
        }
    }

    for (int i = 0; i < 8; i++)
    for (int j = 0; j < 4; j++) {
        p.cop((i << 6) | (j << 4), 0b101);
    }

    p.wait();

    for (int i = 0; i < MEMORY_SIZE; i++) {
        assert(ref[i] == top->cmem->mem[i]);
    }
} AS("random read/write with writeback");