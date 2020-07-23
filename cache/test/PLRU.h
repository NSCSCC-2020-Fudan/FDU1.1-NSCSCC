#include "util.h"
#include "SimpleTopBase.h"

#include <vector>

using select_t = std::vector<u8>;

auto to_bits(const select_t &a) -> u32 {
    u32 r = 0;
    for (int i = 0; i < a.size(); i++) {
        r |= u32(a[i]) << i;
    }
    return r;
}

auto to_vec(u32 v, int n = 7) -> select_t {
    select_t r;
    r.resize(n);
    for (int i = 0; i < n; i++) {
        r[i] = v & 1;
        v >>= 1;
    }
    return r;
}

class Top : public SimpleTopBase {
public:
    auto query_idx(const select_t &a) -> int {
        inst->select = to_bits(a);
        inst->idx = randu(0, 7);
        inst->eval();
        return inst->victim_idx;
    }

    auto query_next(const select_t &a, int idx) -> select_t {
        inst->select = to_bits(a);
        inst->idx = idx;
        inst->eval();
        return to_vec(inst->new_select);
    }
};