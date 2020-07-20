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

WITH {
    constexpr int T = 10000;

    for (int _t = 0; _t < T; _t++) {
        int req = randu(0, 7);
        SelectArray req_s;
        for (int i = 0; i < 7; i++) {
            if ((req >> i) & 1)
                req_s[i] = '1';
            else
                req_s[i] = '0';
        }

        int x = 1;
        for (int i = 0; i < 3; i++) {
            if (req_s[x - 1] == '1')
                x = x * 2 + 1;
            else
                x = x * 2;
        }
        int idx = x - 8;

        int mask;
        switch (idx) {
            case 0: mask = 0b0001011; break;
            case 1: mask = 0b0001011; break;
            case 2: mask = 0b0010011; break;
            case 3: mask = 0b0010011; break;
            case 4: mask = 0b0100101; break;
            case 5: mask = 0b0100101; break;
            case 6: mask = 0b1000101; break;
            case 7: mask = 0b1000101; break;
        }

        auto ret = top->test(req_s);
        assert(ret.idx == idx);
        for (int i = 0; i < 7; i++) {
            int b = ret.next[i] - '0';
            int c = ((req ^ mask) >> i) & 1;
            assert(b == c);
        }
    }
} AS("random");