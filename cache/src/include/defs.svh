`ifndef CACHE_WITHOUT_MIPS
`include "mips.svh"
`endif

`ifndef __CACHE_DEFS_SVH__
`define __CACHE_DEFS_SVH__

parameter int BYTES_PER_WORD = 4;
parameter int BITS_PER_WORD  = BYTES_PER_WORD * 8;

/**
 * utility macros
 */

`ifdef CACHE_WITHOUT_MIPS
`define ASSERT(expr, message) \
    if (!(expr)) \
        $error(message);
`else
`define ASSERT(expr, message) /* nothing */
`endif

/**
 * primitive datatypes
 */

// nibble：half byte
typedef logic [3 :0] nibble_t;

/**
 * since both `byte_t` and `word_t` have been defined in MIPS source
 * in `global.svh`, we cannot have duplicate definitions of them.
 *
 * Remark: ******* VIVADO.
 */
`ifdef CACHE_WITHOUT_MIPS
typedef logic [7 :0] byte_t;
typedef logic [31:0] word_t;
`endif

typedef word_t addr_t;

`endif