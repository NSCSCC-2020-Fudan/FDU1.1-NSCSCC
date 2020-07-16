#include "OneLineBuffer.h"

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH {
    top->issue_read(2, 4 * 31);

    top->print_cache();
    for (int i = 0; i < 18; i++) {
        top->tick();
        top->print_cache();
    }

    assert(top->inst->sramx_resp_x_rdata == 31);
} AS("single read");

WITH {
    for (int i = 0; i < 256; i++) {
        top->tick();
        top->issue_read(2, 4 * i);
        while (!top->inst->sramx_resp_x_data_ok) {
            top->tick();
        }

        printf("%x ?= %x\n", top->inst->sramx_resp_x_rdata, i);
        assert(top->inst->sramx_resp_x_rdata == i);
    }
} AS("sequential read");

WITH TRACE {

} AS("single write");