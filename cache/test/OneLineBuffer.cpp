#include "OneLineBuffer.h"

static auto top = new Top;

WITH TRACE("single-read.fst") {
    top->reset();
    top->issue_read(2, 4 * 7);

    top->print_cache();
    for (int i = 0; i < 18; i++) {
        top->tick();
        top->print_cache();
    }

    assert(top->inst->sramx_resp_x_rdata == 7);
} AS("single read");