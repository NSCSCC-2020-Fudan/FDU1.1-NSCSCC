#include "DCache.h"

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
    Pipeline p(top);
    for (int i = 0; i < MEMORY_SIZE; i++) {
        p.expect(_i(i), i);
    }
    p.wait();
} AS("sequential read");

WITH {
    Pipeline p(top);
    for (int i = 0; i < 256; i++) {
        p.write(_i(i), 0xcccccccc, 0b1111);
    }
    for (int i = 0; i < 256; i++) {
        p.expect(_i(i), 0xcccccccc);
    }
    p.wait();
} AS("memset");