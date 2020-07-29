#include "util.h"
#include "VTop.h"
#include "TopBase.h"
#include "CacheBusMemory.h"

constexpr int MEMORY_DEPTH = 256;

class CacheBusSlave : public ICacheBusSlave {
public:
    CacheBusSlave(VTop *inst) : _inst(inst) {}
    virtual ~CacheBusSlave() {}

    virtual auto valid() -> u8 {
        return _inst->cbus_req_x_valid;
    }
    virtual auto is_write() -> u8 {
        return _inst->cbus_req_x_is_write;
    }
    virtual auto addr() -> u32 {
        return _inst->cbus_req_x_addr;
    }
    virtual auto order() -> u32 {
        return _inst->cbus_req_x_order;
    }
    virtual auto wdata() -> u32 {
        return _inst->cbus_req_x_wdata;
    }

    virtual auto okay() -> u8& {
        return _inst->cbus_resp_x_okay;
    }
    virtual auto last() -> u8& {
        return _inst->cbus_resp_x_last;
    }
    virtual auto rdata() -> u32& {
        return _inst->cbus_resp_x_rdata;
    }
private:
    VTop *_inst;
};

class Top : public TopBase {
public:
    CacheBusMemory *cmem;

    Top() {
        _bus = new CacheBusSlave(inst);
        cmem = new CacheBusMemory(MEMORY_DEPTH, _bus, true);
    }
    virtual ~Top() {
        delete _bus;
        delete cmem;
    }

    void reset() {
        _tickcount = 0;

        inst->clk = 0;
        inst->resetn = 1;
        inst->sramx_req_x_addr = 0;
        inst->sramx_req_x_req = 0;
        inst->sramx_req_x_size = 0;
        inst->sramx_req_x_wdata = 0;
        inst->sramx_req_x_wr = 0;
        inst->cbus_resp_x_last = 0;
        inst->cbus_resp_x_okay = 0;
        inst->cbus_resp_x_rdata = 0;

        inst->resetn = 0;
        tick();
        inst->resetn = 1;
        tick();

        cmem->reset();
    }

    void clock_trigger() {
        cmem->trigger();
    }

    void post_clock_hook() {
        cmem->eval();
    }

    void issue_read(int order, int addr) {
        inst->sramx_req_x_req = 1;
        inst->sramx_req_x_wr = 0;
        inst->sramx_req_x_size = order;
        inst->sramx_req_x_addr = addr;
        inst->sramx_req_x_wdata = 0xcccccccc;
        inst->eval();
    }

    void issue_write(int order, int addr, u32 data) {
        inst->sramx_req_x_req = 1;
        inst->sramx_req_x_wr = 1;
        inst->sramx_req_x_size = order;
        inst->sramx_req_x_addr = addr;
        inst->sramx_req_x_wdata = data;
        inst->eval();
    }

    void print_cache() {
        for (int i = 0; i < 16; i++) {
            info("%x ", inst->mem[i]);
        }
        info("\n");
    }

private:
    CacheBusSlave *_bus;
};
