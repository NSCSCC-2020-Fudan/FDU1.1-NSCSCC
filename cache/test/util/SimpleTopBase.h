#include "VTop.h"

class SimpleTopBase {
public:
    VTop *inst;

    SimpleTopBase() : inst(new VTop) {}
    ~SimpleTopBase() {
        delete inst;
    }

    void eval() {
        inst->eval();
    }

    void eval_step() {
        inst->eval_step();
    }

    void eval_end_step() {
        inst->eval_end_step();
    }
};