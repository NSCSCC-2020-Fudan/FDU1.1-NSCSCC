#include "LoadStoreBuffer.h"

static auto top = new Top;
static Pipeline p(top);

PRETEST_HOOK [] {
    top->reset();
};

WITH {
    for (int i = 0; i < 32; i++) {
        top->issue_load(0x12345678);
        top->tick();
    }
    top->reset();
    for (int i = 0; i < 256; i++) {
        assert(top->inst->s_req_x_req == 0);
        top->tick();
    }
} AS("nop");

WITH LOG {
    p.write(0x12345678, 0x87654321);
    p.inspect(0x11223344);
    p.wait(256);
} AS("simple test");

WITH {
    for (int i = 0; i < 256; i++) {
        p.write(randu(), randu());
    }
    p.inspect(randu());
    p.wait(8192);
} AS("full store");

WITH {
    for (int i = 0; i < 8; i++) {
        p.write(randu(), randu());
    }
    for (int i = 0; i < 256; i++) {
        p.inspect(randu());
    }
    p.wait(8192);
} AS("full load");

WITH {
    for (int i = 0; i < 256; i++) {
        p.write(randu(), randu());
        p.inspect(randu());
    }
    p.wait(8192);
} AS("interleave 1");

WITH {
    for (int i = 0; i < 256; i++) {
        p.inspect(randu());
        p.write(randu(), randu());
    }
    p.wait(8192);
} AS("interleave 2");

WITH SKIP {
    constexpr int T = 1000000;

    for (int _t = 0; _t < T; _t++) {
        int op = randu(0, 1);

        if (op == 0)
            p.write(randu(), randu());
        if (op == 1)
            p.inspect(randu());
    }

    p.wait(T * 16);
} AS("random");

WITH SKIP {
    constexpr int T = 3000000;

    for (int _t = 0; _t < T; _t++) {
        int op = randu(0, 2);

        if (op == 0)
            p.write(randu(), randu());
        if (op == 1)
            p.inspect(randu());
        if (op == 2)
            p.tick();
    }

    p.wait(T * 16);
} AS("random with tick");

WITH {
    for (int i = 0; i < 256; i++) {
        top->issue_load(randu());
        top->inst->m_req_x_req = 0;
        top->eval();

        for (int j = 0; j < 256; j++) {
            assert(top->inst->m_resp_x_data_ok == 0);
        }
    }
} AS("fake load");

WITH {
    for (int i = 0; i < 256; i++) {
        top->issue_store(randu(), randu());
        top->inst->m_req_x_req = 0;
        top->eval();

        for (int j = 0; j < 256; j++) {
            assert(top->inst->m_resp_x_data_ok == 0);
        }
    }
} AS("fake store");