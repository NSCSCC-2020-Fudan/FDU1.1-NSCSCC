#include "PrefixSum.h"

static auto top = new Top;

WITH {
    vec_t in = {0, 1, 1, 0, 1, 1, 1, 1};
    vec_t out = {0, 0, 0, 0, 1, 1, 1, 1};
    auto ret = top->test(in);
    assert(ret == out);
} AS("simple test");

WITH {
    constexpr int T = 1000000;
    for (int _t = 0; _t < T; _t++) {
        vec_t in;
        in.resize(8);
        for (int i = 0; i < 8; i++) {
            in[i] = randu(0, 1);
        }
        vec_t out = in;
        for (int i = 6; i >= 0; i--) {
            out[i] &= out[i + 1];
        }
        auto ret = top->test(in);
        assert(ret == out);
    }
} AS("random test");