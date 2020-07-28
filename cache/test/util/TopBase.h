#include "SimpleTopBase.h"
#include "verilated_fst_c.h"

#include <string>

inline void escape_space(std::string &s) {
    for (auto &c : s) {
        if (c == ' ' || c == '/')
            c = '-';
    }
}

#define TRACE { \
    auto path = std::string(name); \
    escape_space(path); \
    path = "trace/" + path + ".fst"; \
    top->start_trace(path.c_str()); \
    _.defer([] { top->stop_trace(); }); \
}

class TopBase : public SimpleTopBase {
public:
    virtual ~TopBase() {
        stop_trace();
    }

    void tick() {
        _tickcount++;
        u64 now = 10 * _tickcount;

        inst->eval();
        pre_clock_hook();
        inst->eval();
        trace_dump(now - 7);

        inst->clk = 1;
        clock_trigger();
        inst->eval_step();
        trace_dump(now);

        inst->eval_end_step();
        inst->clk = 0;
        inst->eval();
        trace_dump(now + 1);

        post_clock_hook();
        inst->eval();
        trace_dump(now + 2);

        trace_flush();
    }

    void tick(u64 count) {
        for (u64 i = 0; i < count; i++) {
            tick();
        }
    }

    virtual void reset() {}
    virtual void pre_clock_hook() {}
    virtual void clock_trigger() {}
    virtual void post_clock_hook() {}

    void trace_dump(u64 time) {
        if (_trace_fp)
            _trace_fp->dump(static_cast<vluint64_t>(time));
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

        tick();
        // _trace_fp->dump(0);
    }

    void stop_trace() {
        if (_trace_fp) {
            notify("trace: stop @%d\n", tickcount());
            tick();
            _trace_fp->dump(static_cast<vluint64_t>(tickcount() + 10));
            _trace_fp->flush();
            _trace_fp->close();
            delete _trace_fp;
            _trace_fp = nullptr;
        }
    }

    u64 tickcount() const {
        return 10 * _tickcount;
    }

protected:
    u64 _tickcount;
    VerilatedFstC *_trace_fp;
};
