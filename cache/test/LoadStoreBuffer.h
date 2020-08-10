#include "util.h"
#include "TopBase.h"

#include <queue>

class Top : public TopBase {
public:
    void reset() {
        _tickcount = 0;
        inst->clk = 0;
        inst->resetn = 1;
        inst->m_req_x_addr = 0;
        inst->m_req_x_req = 0;
        inst->m_req_x_write_en = 0;
        inst->m_req_x_data = 0;
        inst->m_req_x_is_write = 0;
        inst->s_resp_x_addr_ok = 0;
        inst->s_resp_x_data_ok = 0;
        inst->s_resp_x_data = 0;
        inst->eval();

        inst->resetn = 0;
        tick();
        inst->resetn = 1;
        tick();

        _sw_bits = 0;
        _sw_count = 0;
        _sw_bits_reg = 0;
        _sw_count_reg = 0;
    }

    auto current(int addr, bool use_reg = false) -> u32 {
        return use_reg ? _sw_count_reg : _sw_count;
        // return (addr * _sw_count) ^ _sw_bits;
    }

    void pre_clock_hook() {
        // "data_ok" is delayed by at least one clock cycle.
        if (!_fifo.empty()) {
            inst->s_resp_x_data_ok = randu(0, 1) == 0;

            if (inst->s_resp_x_data_ok) {
                inst->s_resp_x_data = _fifo.front();
                _fifo.pop();
            } else {
                inst->s_resp_x_data = 0xdeadbeef;
            }
        } else
            inst->s_resp_x_data_ok = 0;

        if (inst->s_req_x_req) {
            inst->s_resp_x_addr_ok = randu(0, 3) != 3;

            if (inst->s_resp_x_addr_ok)
                _fifo.push(current(inst->s_req_x_addr, true));
        } else
            inst->s_resp_x_addr_ok = 0;
    }

    void clock_trigger() {
        if (inst->m_req_x_req && inst->m_req_x_is_write && inst->m_resp_x_addr_ok) {
            _sw_bits_reg ^= inst->m_req_x_data;
            _sw_count_reg++;

            if (inst->resetn) {
                assert(_sw_bits_reg == _sw_bits);
                assert(_sw_count_reg == _sw_count);
            }
        }
    }

    void issue_store(int addr, u32 wdata) {
        inst->m_req_x_req = 1;
        inst->m_req_x_write_en = 0b1111;
        inst->m_req_x_is_write = 1;
        inst->m_req_x_addr = addr;
        inst->m_req_x_data = wdata;

        _sw_bits ^= inst->m_req_x_data;
        _sw_count++;

        inst->eval();
    }

    void issue_load(int addr) {
        inst->m_req_x_req = 1;
        inst->m_req_x_write_en = 0b1111;
        inst->m_req_x_is_write = 0;
        inst->m_req_x_addr = addr;
        inst->m_req_x_data = 0xdeadbeef;
        inst->eval();
    }

private:
    u32 _sw_bits, _sw_count;
    u32 _sw_bits_reg, _sw_count_reg;
    std::queue<u32> _fifo;
};

class Pipeline {
public:
    Pipeline(Top *top) : _top(top) {
        top->add_clock_trigger([this] {
            this->addr_ok = this->_top->inst->m_resp_x_addr_ok;
            this->data_ok = this->_top->inst->m_resp_x_data_ok;
            this->data = this->_top->inst->m_resp_x_data;
        });
    }

    void inspect(int addr) {
        _a_fifo.push({false, addr, _top->current(addr)});

        if (!in_req())
            _top->issue_load(addr);
    }

    void write(int addr, u32 data) {
        _a_fifo.push({true, addr, data});

        if (!in_req())
            _top->issue_store(addr, data);
    }

    void tick() {
        _top->tick();

        if (addr_ok && in_req()) {
            assert(!_a_fifo.empty());
            auto u = _a_fifo.front();
            _a_fifo.pop();

            info("a 0x%x\n", u.addr);
            u.data = _top->current(u.addr);
            _d_fifo.push(u);
        }
        if (data_ok) {
            assert(!_d_fifo.empty());
            auto u = _d_fifo.front();
            info("addr 0x%x, data \"%08x\", got \"%08x\", is_write %d\n",
                u.addr, u.data, data, u.is_write);

            if (!u.is_write)
                assert(u.data == data);

            info("d 0x%x\n", u.addr);
            _d_fifo.pop();
        }

        if (_a_fifo.empty()) {
            in_req() = 0;
            _top->eval();
        } else if (addr_ok || !in_req()) {
            auto u = _a_fifo.front();
            if (u.is_write)
                _top->issue_store(u.addr, u.data);
            else {
                u.data = _top->current(u.addr);
                _top->issue_load(u.addr);
            }
        }
    }

    void wait(int max_count = -1) {
        int count = 0;
        while (!empty() && count != max_count) {
            tick();
            count++;
        }
        assert(count != max_count);
    }

    auto in_req() -> u8& {
        return _top->inst->m_req_x_req;
    }

    bool empty() const {
        return _a_fifo.empty() && _d_fifo.empty();
    }

private:
    struct _task_t {
        bool is_write;
        int addr;
        u32 data;
    };

    Top *_top;
    bool addr_ok;
    bool data_ok;
    u64 data;
    std::queue<_task_t> _a_fifo;
    std::queue<_task_t> _d_fifo;
};