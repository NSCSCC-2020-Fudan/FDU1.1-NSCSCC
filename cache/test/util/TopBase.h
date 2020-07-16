#include "VTop.h"
#include "verilated_fst_c.h"

#define TRACE(filename) { \
    top->start_trace("trace/" filename); \
    _.defer([] { top->stop_trace(); }); \
}

class TopBase {
public:
    VTop *inst;

    TopBase() : inst(new VTop), _tickcount(0), _trace_fp(nullptr) {}
    ~TopBase() {
        stop_trace();
    }

    void tick() {
        _tickcount++;
        int now = 10 * _tickcount;

        inst->eval();
        pre_clock_hook();
        inst->eval();
        trace_dump(now - 2);

        inst->clk = 1;
        clock_trigger();
        inst->eval_step();
        trace_dump(now);

        inst->eval_end_step();
        inst->eval();
        trace_dump(now + 1);

        post_clock_hook();
        inst->eval();
        trace_dump(now + 2);

        inst->clk = 0;
        inst->eval();
        trace_dump(now + 3);
        trace_flush();
    }

    void tick(int count) {
        for (int i = 0; i < count; i++) {
            tick();
        }
    }

    virtual void reset() {}
    virtual void pre_clock_hook() {}
    virtual void clock_trigger() {}
    virtual void post_clock_hook() {}

    void trace_dump(int time) {
        if (_trace_fp)
            _trace_fp->dump(time);
    }

    void trace_flush() {
        if (_trace_fp)
            _trace_fp->flush();
    }

    void start_trace(const char *filename) {
        if (_trace_fp)
            stop_trace();

        _trace_fp = new VerilatedFstC;
        inst->trace(_trace_fp, 32);
        _trace_fp->open(filename);
        _trace_fp->dump(0);
    }

    void stop_trace() {
        if (_trace_fp) {
            _trace_fp->dump(10 * _tickcount + 20);
            _trace_fp->close();
            delete _trace_fp;
            _trace_fp = nullptr;
        }
    }

protected:
    int _tickcount;
    VerilatedFstC *_trace_fp;
};
