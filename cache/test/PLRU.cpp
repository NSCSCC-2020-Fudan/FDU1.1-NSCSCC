#include "PLRU.h"

static auto top = new Top;

WITH {
    auto ret = top->test("00000000");
    assert(ret.idx == 0);
    for (int i = 0; i < 7; i++) {
        if ((i & (i + 1)) == 0)
            assert(ret.next[i] == '1');
        else
            assert(ret.next[i] == '0');
    }
} AS("simple");