`ifndef __MEMORY_SVH
`define __MEMORY_SVH

typedef struct packed {
    logic regwrite;
    logic memread;
    creg_addr_t writereg;
    word_t readdata, aluout;
} mem_data_t;

`endif
