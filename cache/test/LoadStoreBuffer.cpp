#include "LoadStoreBuffer.h"

static auto top = new Top;
static Pipeline p(top);

PRETEST_HOOK [] {
    top->reset();
};

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
} AS("interleave");