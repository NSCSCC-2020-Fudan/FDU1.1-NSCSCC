#include "util.h"

class ICacheBusMaster {
public:
    virtual auto valid() -> u8& = 0;
    virtual auto is_write() -> u8& = 0;
    virtual auto addr() -> u32& = 0;
    virtual auto order() -> u32& = 0;
    virtual auto wdata() -> u32& = 0;

    virtual auto okay() -> u8 = 0;
    virtual auto last() -> u8 = 0;
    virtual auto rdata() -> u32 = 0;
};

class ICacheBusSlave {
public:
    virtual auto valid() -> u8 = 0;
    virtual auto is_write() -> u8 = 0;
    virtual auto addr() -> u32 = 0;
    virtual auto order() -> u32 = 0;
    virtual auto wdata() -> u32 = 0;

    virtual auto okay() -> u8& = 0;
    virtual auto last() -> u8& = 0;
    virtual auto rdata() -> u32& = 0;
};