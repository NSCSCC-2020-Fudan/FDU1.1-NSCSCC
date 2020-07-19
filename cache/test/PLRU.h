#include "util.h"
#include "SimpleTopBase.h"

typedef char SelectArray[7];

struct Result {
    Result() : idx(0) {
        memset(next, 0, sizeof(next));
    }

    int idx;
    SelectArray next;
};

class Top : public SimpleTopBase {
public:
    auto test(const SelectArray a) -> Result {
        inst->select = 0;
        for (int i = 0; i < 7; i++) {
            if (a[i] == '1')
                inst->select |= 1 << i;
        }

        inst->eval();

        Result rax;
        rax.idx = inst->idx;
        for (int i = 0; i < 7; i++) {
            if ((inst->new_select >> i) & 1)
                rax.next[i] = '1';
            else
                rax.next[i] = '0';
        }

        return rax;
    }
};