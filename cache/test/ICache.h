#include "util.h"
#include "VTop.h"
#include "TopBase.h"
#include "CacheBusMemory.h"

constexpr int MEMORY_SIZE = 262144;  // 256KB

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

    void issue_read(int addr, int vaddr) {
        int zeros = vaddr & 0x3;
        int shamt = (vaddr & 0x4) >> 2;
        int offset = (vaddr & 0x18) >> 3;
        int index = (vaddr & 0x60) >> 5;
        int tag = (vaddr & 0xffffff80) >> 7;

        inst->ibus_req_x_req = 1;
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

private:
    CacheBusSlave *_bus;
};