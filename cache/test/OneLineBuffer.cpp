#include "util.h"
#include "VTop.h"

static auto top = new VTop;

WITH {
    // printf("%x\n", top->cbus_req_x_addr);
} AS("test");