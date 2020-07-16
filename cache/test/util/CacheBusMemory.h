#include "ICacheBus.h"

#include <cstdio>
#include <cassert>

class CacheBusMemory {
public:
    int size;
    u32 *mem;

    CacheBusMemory(int _size, ICacheBusSlave *bus)
        : size(_size), mem(new u32[size]), _bus(bus) {
        reset();
    }
    ~CacheBusMemory() {
        delete[] mem;
    }

    void reset() {
        _in_operation = false;
        _count = 0;
        for (int i = 0; i < size; i++) {
            mem[i] = i;
        }

        _bus->okay() = 0;
        _bus->last() = 0;
        _bus->rdata() = 0;
    }

    auto get_index() const -> int {
        assert((_bus->addr() % 4) == 0);
        int index = _bus->addr() / 4 + _count;
        assert(0 <= index && index < size);
        return index;
    }

    void trigger() {
        if (_in_operation) {
            if (_bus->is_write()) {
                int index = get_index();
                printf("$bus: write: mem[%d] = %x\n", index, _bus->wdata());
                mem[index] = _bus->wdata();
            }

            _count++;

            if (_count == (1 << _bus->order())) {
                _in_operation = false;
            }
        } else {
            if (_bus->valid()) {
                _in_operation = true;
                _count = 0;
            }
        }
    }

    void eval() const {
        _bus->okay() = _in_operation;
        bool is_last = _count == (1 << _bus->order()) - 1;
        _bus->last() = is_last;
        _bus->rdata() = mem[get_index()];
    }

private:
    ICacheBusSlave *_bus;
    bool _in_operation;
    int _count;
};