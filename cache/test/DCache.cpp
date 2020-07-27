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