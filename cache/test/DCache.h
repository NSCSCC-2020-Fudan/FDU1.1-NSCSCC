#include "util.h"
#include "VTop.h"
#include "TopBase.h"
#include "CacheBusMemory.h"

#include <tuple>
#include <queue>

constexpr int MEMORY_SIZE = 262144;  // 1MB

auto parse_vaddr(int vaddr) -> std::tuple<int, int, int, int> {
    int zeros = vaddr & 0x3;
    int offset = (vaddr >> 2) & 0x3;
    int index = (vaddr >> 4) & 0x3;
    int tag = (vaddr >> 6) & 0x3ffffff;
    return std::make_tuple(tag, index, offset, zeros);
}

int _i(int i) {
    return i << 2;
}

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
        cmem = new CacheBusMemory(MEMORY_SIZE, _bus, true);
    }
    virtual ~Top() {
        delete _bus;
        delete cmem;
    }

    void reset(bool reset_tick = true) {
        if (reset_tick)
            _tickcount = 0;

        inst->clk = 0;
        inst->resetn = 1;
        inst->dbus_req_x_cache_op_x_req = 0;
        inst->dbus_req_x_cache_op_x_funct_x_as_index = 0;
        inst->dbus_req_x_cache_op_x_funct_x_invalidate = 0;
        inst->dbus_req_x_cache_op_x_funct_x_writeback = 0;
        inst->dbus_req_vaddr_x_index = 0;
        inst->dbus_req_vaddr_x_offset = 0;
        inst->dbus_req_vaddr_x_tag = 0;
        inst->dbus_req_vaddr_x_zeros = 0;
        inst->dbus_req_x_addr = 0;
        inst->dbus_req_x_data = 0;
        inst->dbus_req_x_is_write = 0;
        inst->dbus_req_x_req = 0;
        inst->dbus_req_x_write_en = 0;
        inst->cbus_resp_x_okay = 0;
        inst->cbus_resp_x_last = 0;
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

    void reset_req() {
        inst->dbus_req_x_req = 0;
    }

    void issue_cop(int addr, int vaddr, int opcode) {
        // format: {as_index, invalidate, writeback}

        std::tie(
            inst->dbus_req_vaddr_x_tag,
            inst->dbus_req_vaddr_x_index,
            inst->dbus_req_vaddr_x_offset,
            inst->dbus_req_vaddr_x_zeros
        ) = parse_vaddr(vaddr);
        inst->dbus_req_x_req = 1;
        inst->dbus_req_x_cache_op_x_req = 1;
        inst->dbus_req_x_cache_op_x_funct_x_as_index = (opcode >> 2) & 1;
        inst->dbus_req_x_cache_op_x_funct_x_invalidate = (opcode >> 1) & 1;
        inst->dbus_req_x_cache_op_x_funct_x_writeback = (opcode >> 0) & 1;
        inst->dbus_req_x_addr = addr;
        inst->dbus_req_x_data = 0xcccccccd;
        inst->dbus_req_x_is_write = 1;
        inst->dbus_req_x_write_en = 0b1111;

        inst->eval();
    }

    void issue_read(int addr, int vaddr) {
        std::tie(
            inst->dbus_req_vaddr_x_tag,
            inst->dbus_req_vaddr_x_index,
            inst->dbus_req_vaddr_x_offset,
            inst->dbus_req_vaddr_x_zeros
        ) = parse_vaddr(vaddr);
        inst->dbus_req_x_req = 1;
        inst->dbus_req_x_cache_op_x_req = 0;
        inst->dbus_req_x_cache_op_x_funct_x_as_index = 1;
        inst->dbus_req_x_cache_op_x_funct_x_invalidate = 1;
        inst->dbus_req_x_cache_op_x_funct_x_writeback = 1;
        inst->dbus_req_x_is_write = 0;
        inst->dbus_req_x_write_en = 0;  // must be zeros if "is_write" is zero
        inst->dbus_req_x_addr = addr;
        inst->dbus_req_x_data = 0xcccccccc;

        inst->eval();
    }

    void issue_write(int addr, int vaddr, u32 data, int mask) {
        std::tie(
            inst->dbus_req_vaddr_x_tag,
            inst->dbus_req_vaddr_x_index,
            inst->dbus_req_vaddr_x_offset,
            inst->dbus_req_vaddr_x_zeros
        ) = parse_vaddr(vaddr);
        inst->dbus_req_x_req = 1;
        inst->dbus_req_x_cache_op_x_req = 0;
        inst->dbus_req_x_cache_op_x_funct_x_as_index = 1;
        inst->dbus_req_x_cache_op_x_funct_x_invalidate = 1;
        inst->dbus_req_x_cache_op_x_funct_x_writeback = 1;
        inst->dbus_req_x_is_write = 1;
        inst->dbus_req_x_write_en = mask;
        inst->dbus_req_x_addr = addr;
        inst->dbus_req_x_data = data;

        inst->eval();
    }

    void issue_read(int addr) {
        issue_read(addr, addr);
    }

    void issue_write(int addr, u32 data) {
        issue_write(addr, addr, data, 0b1111);
    }

private:
    CacheBusSlave *_bus;
};

class Pipeline {
public:
    Pipeline(Top *top) : _top(top) {}

    void expect(int paddr, u32 data, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        _a_fifo.push({0, paddr, vaddr, 0, data, nullptr});

        if (!in_req())
            _top->issue_read(paddr, vaddr);
    }

    void read(int paddr, u32 *dest, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        _a_fifo.push({0, paddr, vaddr, 0, 0, dest});

        if (!in_req())
            _top->issue_read(paddr, vaddr);
    }

    void write(int paddr, u32 data, int mask, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        _a_fifo.push({0, paddr, vaddr, mask, data, nullptr});

        if (!in_req())
            _top->issue_write(paddr, vaddr, data, mask);
    }

    void cop(int paddr, int op, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        _a_fifo.push({op, paddr, vaddr, 0, 0, nullptr});

        if (!in_req())
            _top->issue_cop(paddr, vaddr, op);
    }

    void wait(int max_count = -1) {
        int count = 0;
        while (!empty() && count != max_count) {
            tick();
            count++;
        }
        assert(count != max_count);
    }

    void tick() {
        bool addr_ok = _top->inst->dbus_resp_x_addr_ok;
        bool data_ok = _top->inst->dbus_resp_x_data_ok;
        u64 data = _top->inst->dbus_resp_x_data;

        _top->tick();

        if (addr_ok && in_req()) {
            assert(!_a_fifo.empty());
            _d_fifo.push(_a_fifo.front());
            _a_fifo.pop();
        }

        if (data_ok) {
            assert(!_d_fifo.empty());
            auto u = _d_fifo.front();

            if (u.is_cop())
                info("cop 0x%x, paddr 0x%08x, vaddr 0x%08x\n", u.cop, u.paddr, u.vaddr);
            else {
                info(
                    "addr 0x%x (v:0x%x), %s \"%08x\", got \"%08x\" (mask:0x%x, dest:%s)\n",
                    u.paddr, u.vaddr,
                    (u.is_read() ? "expect" : "write"),
                    u.data, data, u.mask,
                    (u.dest ? "yes" : "no")
                );

                if (u.dest)
                    *u.dest = data;
                else if (u.is_read())
                    assert(u.data == data);
            }

            _d_fifo.pop();
        }

        if (_a_fifo.empty()) {
            in_req() = 0;
            _top->eval();
        } else {
            auto u = _a_fifo.front();
            if (u.is_cop())
                _top->issue_cop(u.paddr, u.vaddr, u.cop);
            else if (u.mask)
                _top->issue_write(u.paddr, u.vaddr, u.data, u.mask);
            else
                _top->issue_read(u.paddr, u.vaddr);
        }
    }

    auto in_req() -> u8& {
        return _top->inst->dbus_req_x_req;
    }

    bool empty() const {
        return _a_fifo.empty() && _d_fifo.empty();
    }

private:
    struct _task_t {
        int cop;
        int paddr;
        int vaddr;
        int mask;
        u32 data;
        u32 *dest;

        bool is_cop() const {
            return cop;
        }

        bool is_read() const {
            return !is_cop() && !mask;
        }
    };

    Top *_top;
    std::queue<_task_t> _a_fifo, _d_fifo;
};