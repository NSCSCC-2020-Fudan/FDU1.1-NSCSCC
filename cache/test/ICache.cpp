#include "ICache.h"

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH TRACE {
    top->reset(false);
    top->issue_read(4);
    top->tick(256);
    assert(top->inst->ibus_resp_x_addr_ok == 1);
    assert(top->inst->ibus_resp_x_data_ok == 1);
    assert(top->inst->ibus_resp_x_index == 1);
    assert(top->inst->ibus_resp_x_data == ((u64(remap(1)) << 32) | remap(0)));
} AS("single read");