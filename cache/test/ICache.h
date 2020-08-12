#include "util.h"
#include "VTop.h"
#include "TopBase.h"
#include "CacheBusMemory.h"

#include <queue>

constexpr int MEMORY_SIZE = 262144;  // 1MB

inline u64 remap(int a, int b) {
    assert(a < b);
    return (static_cast<u64>(remap(b)) << 32) | remap(a);
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
        cmem = new CacheBusMemory(MEMORY_SIZE, _bus, true, true);
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
        inst->ibus_req_x_cache_op_x_req = 0;
        inst->ibus_req_x_cache_op_x_funct_x_as_index = 0;
        inst->ibus_req_x_cache_op_x_funct_x_invalidate = 0;
        inst->ibus_req_x_cache_op_x_funct_x_writeback = 0;
        inst->ibus_req_vaddr_x_aligned_x_shamt = 0;
        inst->ibus_req_vaddr_x_aligned_x_zeros = 0;
        inst->ibus_req_vaddr_x_index = 0;
        inst->ibus_req_vaddr_x_offset = 0;
        inst->ibus_req_vaddr_x_tag = 0;
        inst->ibus_req_x_req = 0;
        inst->ibus_req_x_addr = 0;
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

    void issue_cop(int addr, int vaddr, int opcode) {
        int zeros = vaddr & 0x3;
        int shamt = (vaddr & 0x4) >> 2;
        int offset = (vaddr & 0x18) >> 3;
        int index = (vaddr & 0x60) >> 5;
        int tag = (vaddr & 0xffffff80) >> 7;

        inst->ibus_req_x_req = 1;
        inst->ibus_req_x_cache_op_x_req = 1;
        inst->ibus_req_x_cache_op_x_funct_x_as_index = (opcode >> 2) & 1;
        inst->ibus_req_x_cache_op_x_funct_x_invalidate = (opcode >> 1) & 1;
        inst->ibus_req_x_cache_op_x_funct_x_writeback = (opcode >> 0) & 1;
        inst->ibus_req_x_addr = addr;
        inst->ibus_req_vaddr_x_aligned_x_zeros = zeros;
        inst->ibus_req_vaddr_x_aligned_x_shamt = shamt;
        inst->ibus_req_vaddr_x_offset = offset;
        inst->ibus_req_vaddr_x_index = index;
        inst->ibus_req_vaddr_x_tag = tag;

        inst->eval();
    }

    void issue_read(int addr, int vaddr) {
        int zeros = vaddr & 0x3;
        int shamt = (vaddr & 0x4) >> 2;
        int offset = (vaddr & 0x18) >> 3;
        int index = (vaddr & 0x60) >> 5;
        int tag = (vaddr & 0xffffff80) >> 7;

        inst->ibus_req_x_req = 1;
        inst->ibus_req_x_cache_op_x_req = 0;
        inst->ibus_req_x_cache_op_x_funct_x_as_index = 1;
        inst->ibus_req_x_cache_op_x_funct_x_invalidate = 1;
        inst->ibus_req_x_cache_op_x_funct_x_writeback = 1;
        inst->ibus_req_x_addr = addr;
        inst->ibus_req_vaddr_x_aligned_x_zeros = zeros;
        inst->ibus_req_vaddr_x_aligned_x_shamt = shamt;
        inst->ibus_req_vaddr_x_offset = offset;
        inst->ibus_req_vaddr_x_index = index;
        inst->ibus_req_vaddr_x_tag = tag;

        inst->eval();
    }

    void issue_read(int addr) {
        issue_read(addr, addr);
    }

    void reset_req() {
        inst->ibus_req_x_req = 0;
        inst->eval();
    }

private:
    CacheBusSlave *_bus;
};

class Pipeline {
public:
    Pipeline(Top *top) : _top(top) {}

    void cop(int paddr, int opcode, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        _rd_fifo.push({opcode, paddr, vaddr, 0, 0});

        if (!in_req())
            _top->issue_cop(paddr, vaddr, opcode);
    }

    void expect32(int paddr, u32 data, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        int offset = ((paddr & 7) * 8);
        u64 mask = 0xffffffffLU << offset;
        _rd_fifo.push({0, paddr, vaddr, mask, static_cast<u64>(data) << offset});

        if (!in_req())
            _top->issue_read(paddr, vaddr);
    }

    void expect64(int paddr, u64 data, int vaddr = -1) {
        if (vaddr < 0)
            vaddr = paddr;

        int offset = ((paddr & 7) * 8);
        u64 mask = 0xffffffffffffffff << offset;
        _rd_fifo.push({0, paddr, vaddr, mask, data});

        if (!in_req())
            _top->issue_read(paddr, vaddr);
    }

    void expect(int index) {
        int addr = index * 4;
        if (index & 1)
            expect64(addr, static_cast<u64>(remap(index)) << 32);
        else
            expect64(addr, remap(index, index + 1));
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
        bool addr_ok = _top->inst->ibus_resp_x_addr_ok;
        bool data_ok = _top->inst->ibus_resp_x_data_ok;
        u64 raw_data = _top->inst->ibus_resp_x_data;
        int index = _top->inst->ibus_resp_x_index;
        u64 mask = 0xffffffffffffffff << (index * 32);
        u64 data = raw_data & mask;

        _top->tick();

        if (addr_ok && in_req()) {
            assert(!_rd_fifo.empty());
            _wt_fifo.push(_rd_fifo.front());
            _rd_fifo.pop();
        }
        if (data_ok) {
            assert(!_wt_fifo.empty());
            auto u = _wt_fifo.front();

            if (u.cop)
                info("cop %x, vaddr 0x%08x, paddr 0x%08x\n", u.cop, u.paddr, u.vaddr);
            else {
                info(
                    "addr 0x%x (v:0x%x), expect \"%016llx\", got \"%016llx\" (raw: %016llx, index: %d, mask: %016llx)\n",
                    u.paddr, u.vaddr, u.data, data, raw_data, index, u.mask
                );
                assert((u.data & u.mask) == (data & u.mask));
            }

            _wt_fifo.pop();
        }

        if (_rd_fifo.empty()) {
            in_req() = 0;
            _top->eval();
        } else {
            auto u = _rd_fifo.front();

            if (u.cop)
                _top->issue_cop(u.paddr, u.vaddr, u.cop);
            else
                _top->issue_read(u.paddr, u.vaddr);
        }
    }

    auto in_req() -> u8& {
        return _top->inst->ibus_req_x_req;
    }

    bool empty() const {
        return _rd_fifo.empty() && _wt_fifo.empty();
    }

private:
    struct _task_t {
        int cop;
        int paddr;
        int vaddr;
        u64 mask;
        u64 data;
    };

    Top *_top;
    std::queue<_task_t> _rd_fifo, _wt_fifo;
};