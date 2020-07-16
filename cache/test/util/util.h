#pragma once

#include <vector>
#include <functional>

using u8 = unsigned char;
using u32  = unsigned int;
using u64  = unsigned long long;
using cstr = const char*;

using PretestHook  = std::function<void(void)>;
using PosttestHook = std::function<void(void)>;
using DeferHook    = std::function<void(void)>;  // mimic Go's `defer`

extern PretestHook   _pretest_hook;
extern PosttestHook  _posttest_hook;

extern std::vector<DeferHook> _global_defers;

class ITestbench {
public:
    cstr name;

    ITestbench(cstr _name);
    void run();

private:
    virtual void _run() = 0;
};

class DeferList {
public:
    ~DeferList();
    void defer(const DeferHook &fn);

private:
    std::vector<DeferHook> _defers;
};

/**
 * example:
 * PRETEST_HOOK [] {
 *     dev->reset();
 * };
 * POSTTEST_HOOK [] {
 *     // source code here.
 * };
 */
#define PRETEST_HOOK static struct __PretestHookSetter { \
    __PretestHookSetter(const PretestHook &fn) { \
        _set_pretest_hook() = fn; \
    } \
} __pretest_hook_setter_inst = (PretestHook)

#define POSTTEST_HOOK static struct __PosttestHookSetter { \
    __PosttestHookSetter(const PosttestHook &fn) { \
        _set_posttest_hook() = fn; \
    } \
} __posttest_hook_setter_inst = (PosttestHook)

// unique id magic: https://stackoverflow.com/a/2419720/7434327
#define _TESTBENCH_CAT_IMPL(x, y) x##y
#define _TESTBENCH_CAT(x, y) _TESTBENCH_CAT_IMPL(x, y)
#define _TESTBENCH_UNIQUE(x) _TESTBENCH_CAT(x, __LINE__)

#define _TESTBENCH_BEGIN(id) \
    static class id : public ITestbench { \
        using ITestbench::ITestbench; \
        void _run() { \
            DeferList _;

#define _TESTBENCH_END(id, name) \
        } \
    } id(name);

/**
 * usage:
 * WITH [FUNC1] [FUNC2] ... {
 *     // source code here.
 * } AS("test name")
 */
#define WITH _TESTBENCH_BEGIN(_TESTBENCH_UNIQUE(__Testbench))
#define AS(name) _TESTBENCH_END(_TESTBENCH_UNIQUE(__testbench), name)

/**
 * [FUNC]: functional directives.
 *
 * NOTE: it is recommended not to implement them in this file.
 */
// #define TRACE { dev->enable_print(); }
// #define STATISTICS { _.defer([] { \
//     dev->print_statistics(); \
// }); }

// invoke in `main`:
void run_tests();

auto _set_pretest_hook() -> PretestHook&;
auto _set_posttest_hook() -> PosttestHook&;

u32 randu(u32 l, u32 r);