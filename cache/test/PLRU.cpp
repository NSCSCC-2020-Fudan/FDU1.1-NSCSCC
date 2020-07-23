#include "PLRU.h"

static auto top = new Top;

auto random_select(int n = 7) -> select_t {
    select_t s;
    s.resize(n);
    for (int i = 0; i < n; i++) {
        s[i] = randu(0, 1);
    }
    return s;
}

WITH {
    for (int S = 0; S < (1 << 7); S++) {
        auto s = to_vec(S);
        int got = top->query_idx(s);
        int ans = 0, x = 1;
        for (int i = 0; i < 3; i++) {
            ans |= s[x - 1] << (2 - i);
            x = 2 * x + s[x - 1];
        }

        assert(got == ans);
    }
} AS("replace test");

WITH {
    constexpr int T = 100000;

    for (int _t = 0; _t < T; _t++) {
        auto s = random_select();
        int got = top->query_idx(s);
        int ans = 0, x = 1;
        for (int i = 0; i < 3; i++) {
            ans |= s[x - 1] << (2 - i);
            x = 2 * x + s[x - 1];
        }

        assert(got == ans);
    }
} AS("random replace test");

WITH {
    for (int S = 0; S < (1 << 7); S++)
    for (int idx = 0; idx < 7; idx++) {
        auto s = to_vec(S);
        auto got = top->query_next(s, idx);
        auto ans = s;

        int x = 1;
        for (int i = 2; i >= 0; i--) {
            int b = (idx >> i) & 1;
            ans[x - 1] = !b;
            x = 2 * x + b;
        }

        assert(got == ans);
    }
} AS("hit test");

WITH {
    constexpr int T = 100000;

    for (int _t = 0; _t < T; _t++) {
        auto s = random_select();
        int idx = randu(0, 7);

        auto got = top->query_next(s, idx);
        auto ans = s;

        int x = 1;
        for (int i = 2; i >= 0; i--) {
            int b = (idx >> i) & 1;
            ans[x - 1] = !b;
            x = 2 * x + b;
        }

        assert(got == ans);
    }
} AS("random hit test");