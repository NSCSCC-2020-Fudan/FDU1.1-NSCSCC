#include "ICacheBus.h"

#include <cstdio>
#include <cassert>

inline u32 remap(int i) {
    // Knuth's multiplicative hash
    return (i + 1) * 2654435761u;
}

class CacheBusMemory {
public:
    int size;
    u32 *mem;

    CacheBusMemory(
        int _size, ICacheBusSlave *bus,
        bool random_delay = false,
        bool use_hash = false
    ) : size(_size), mem(new u32[size]), _bus(bus),
        _random_delay(random_delay), _use_hash(use_hash) {
        reset();
    }
    ~CacheBusMemory() {
        delete[] mem;
    }

    void reset() {
        _delayed = false;
        _in_operation = false;
        _count = 0;
        for (int i = 0; i < size; i++) {
            if (_use_hash)
                mem[i] = remap(i);
            else
                mem[i] = i;
        }

        _bus->okay() = 0;
        _bus->last() = 0;
        _bus->rdata() = 0;
    }

    auto get_index() const -> int {
        assert((_bus->addr() % 4) == 0);
        int index;
        if (_in_operation) {
            // support AXI wrap burst access.
            // this may not be compatible with AXI incr burst, but
            // it is generally okay in cache read/write settings.

            // index = _bus->addr() / 4 + _count;

            int req_size = 1 << _bus->order();
            int req_index = _bus->addr() / 4;
            int wrap_boundary = req_index / req_size * req_size;
            int req_offset = req_index - wrap_boundary;
            int cur_offset = (req_offset + _count) % req_size;
            index = wrap_boundary + cur_offset;
        } else
            index = _bus->addr() / 4;
        assert(0 <= index && index < size);
        return index;
    }

    void trigger() {
        if (_in_operation) {
            if (!_delayed) {
                if (_bus->is_write()) {
                    int index = get_index();
                    info("$bus: write: mem[%d] = %x\n", index, _bus->wdata());
                    mem[index] = _bus->wdata();
                }

                _count++;

                if (_count == (1 << _bus->order())) {
                    _in_operation = false;
                }
            }
            _delayed = false;
        } else {
            if (_bus->valid()) {
                _in_operation = true;
                _count = 0;
            }
        }
    }

    void eval() {
        _delayed = _random_delay ? randu(0, 1) : 0;
        bool okay = _in_operation && !_delayed;
        bool is_last = _count == (1 << _bus->order()) - 1;

        _bus->okay() = okay;
        _bus->last() = okay && is_last;
        _bus->rdata() = mem[get_index()];
    }

private:
    ICacheBusSlave *_bus;
    bool _random_delay;
    bool _use_hash;
    bool _delayed;
    bool _in_operation;
    int _count;
};