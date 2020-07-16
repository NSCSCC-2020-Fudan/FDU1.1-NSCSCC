#include "util.h"

#include <cassert>
#include <cstdio>
#include <vector>

#include <unistd.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>

#define GREEN "\033[32m"
#define RED   "\033[31m"
#define RESET "\033[0m"

using TestList = std::vector<class ITestbench*>;

static TestList _test_list;
static auto _do_nothing = []{};

ITestbench   *_current_test  = nullptr;
TestList     *_p_test_list   = &_test_list;
PretestHook   _pretest_hook  = _do_nothing;
PosttestHook  _posttest_hook = _do_nothing;

ITestbench::ITestbench(cstr _name) : name(_name) {
    _p_test_list->push_back(this);
}

void ITestbench::run() {
    _current_test = this;

    _pretest_hook();
    _run();
    _posttest_hook();

    auto fmt = isatty(STDOUT_FILENO) ?
        GREEN "[OK]" RESET " %s\n" :
        "[OK] %s\n";
    printf(fmt, name);
    _current_test = nullptr;
}

// signal handling from CS:APP
using handler_t = void(int);

void hook_signal(int sig, handler_t *handler) {
    struct sigaction action;

    action.sa_handler = handler;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_RESTART;

    assert(sigaction(sig, &action, NULL) >= 0);
}

void abort_handler(int) {
    auto fmt = isatty(STDERR_FILENO) ?
        RED "ERR!" RESET " abort in \"%s\"\n":
        "ERR! abort in \"%s\"\n";

    if (_current_test)
        fprintf(stderr, fmt, _current_test->name);
    fflush(stdout);
}

void exit_handler() {
    abort_handler(0);
}

void run_tests() {
    hook_signal(SIGABRT, abort_handler);
    atexit(exit_handler);

    int count = 0;
    for (auto t : *_p_test_list) {
        t->run();
        count++;
    }

    printf("%d test(s) passed.\n", count);
}

auto _set_pretest_hook() -> PretestHook& { \
    return _pretest_hook; \
}

auto _set_posttest_hook() -> PosttestHook& { \
    return _posttest_hook; \
}
