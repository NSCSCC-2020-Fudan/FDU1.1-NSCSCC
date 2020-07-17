`ifndef __CACHE_DEFS_SVH__
`define __CACHE_DEFS_SVH__

parameter int BYTES_PER_WORD = 4;
parameter int BITS_PER_WORD  = BYTES_PER_WORD * 8;

/**
 * utility macros
 */

`define ASSERT(expr, message) \
    if (!(expr)) \
        $error(message);

/**
 * primitive datatypes
 */

// nibble：half byte
typedef logic [3 :0] nibble_t;
typedef logic [7 :0] byte_t;
typedef logic [31:0] word_t;

typedef word_t addr_t;

`endif