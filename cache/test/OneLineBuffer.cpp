#include "util.h"
#include "VTop.h"
#include "CacheBusMemory.h"

#include <cassert>

#include "verilated_fst_c.h"

class CacheBusSlave : public ICacheBusSlave {
public:
    CacheBusSlave(VTop *inst) : _inst(inst) {}

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

class Top {
public:
    VTop *inst;

    Top() : inst(new VTop) {
        _bus = new CacheBusSlave(inst);
        _mem = new CacheBusMemory(256, _bus);
        _trace_fp = nullptr;
    }
    ~Top() {
        delete inst;
        delete _bus;
        delete _mem;
    }

    void tick() {
        _tickcount++;

        inst->eval();
        pre_clock_hook();
        inst->eval();
        trace_dump(10 * _tickcount - 2);

        inst->clk = 1;
        _mem->trigger();
        inst->eval_step();
        trace_dump(10 * _tickcount);

        inst->eval_end_step();
        _mem->eval();
        inst->eval();
        trace_dump(10 * _tickcount + 1);

        post_clock_hook();
        inst->eval();
        trace_dump(10 * _tickcount + 2);

        inst->clk = 0;
        inst->eval();
        trace_dump(10 * _tickcount + 3);
        trace_flush();
    }

    void tick(int count) {
        for (int i = 0; i < count; i++) {
            tick();
        }
    }

    void reset() {
        _tickcount = 0;

        inst->clk = 0;
        inst->reset = 0;
        inst->sramx_req_x_addr = 0;
        inst->sramx_req_x_req = 0;
        inst->sramx_req_x_size = 0;
        inst->sramx_req_x_wdata = 0;
        inst->sramx_req_x_wr = 0;
        inst->cbus_resp_x_last = 0;
        inst->cbus_resp_x_okay = 0;
        inst->cbus_resp_x_rdata = 0;

        inst->reset = 1;
        tick();
        inst->reset = 0;
        tick();
    }

    void pre_clock_hook() {

    }

    void post_clock_hook() {

    }

    void issue_read(int order, int addr) {
        inst->sramx_req_x_req = 1;
        inst->sramx_req_x_wr = 0;
        inst->sramx_req_x_size = order;
        inst->sramx_req_x_addr = addr;
        inst->sramx_req_x_wdata = 0xcccccccc;
    }

    void print_cache() {
        for (int i = 0; i < 16; i++) {
            printf("%x ", inst->mem[i]);
        }
        puts("");
    }

    void trace_dump(int time) {
        if (_trace_fp)
            _trace_fp->dump(time);
    }

    void trace_flush() {
        if (_trace_fp)
            _trace_fp->flush();
    }

    void start_trace(cstr filename) {
        _trace_fp = new VerilatedFstC;
        inst->trace(_trace_fp, 32);
        _trace_fp->open(filename);
        _trace_fp->dump(0);
    }

    void stop_trace() {
        _trace_fp->dump(10 * _tickcount + 20);
        _trace_fp->close();
        delete _trace_fp;
        _trace_fp = nullptr;
    }

private:
    int _tickcount;
    CacheBusSlave *_bus;
    CacheBusMemory *_mem;
    VerilatedFstC *_trace_fp;
};

static auto top = new Top;

WITH {
    top->reset();
    top->issue_read(2, 4 * 7);

    top->start_trace("trace/single-read.fst");
    top->print_cache();
    for (int i = 0; i < 18; i++) {
        top->tick();
        top->print_cache();
    }

    top->stop_trace();
    assert(top->inst->sramx_resp_x_rdata == 7);
} AS("single read");