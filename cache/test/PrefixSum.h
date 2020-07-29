#include "util.h"
#include "SimpleTopBase.h"

#include <vector>

typedef std::vector<u8> vec_t;

class Top : public SimpleTopBase {
public:
    auto test(const vec_t &in) -> vec_t {
        u32 bits = 0;
        for (int i = 0; i < in.size(); i++) {
            bits |= static_cast<u32>(in[i]) << i;
        }

        inst->arr = bits;
        inst->eval();

        u32 ret = inst->sum;
        vec_t rax;
        for (int i = 0; i < in.size(); i++) {
            rax.push_back(ret & 1);
            ret >>= 1;
        }

        return rax;
    }
};