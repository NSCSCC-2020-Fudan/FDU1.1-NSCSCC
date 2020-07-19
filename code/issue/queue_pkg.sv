//  Package: queue_pkg
//
package queue_pkg;
    import common::*;
    //  Group: Parameters
    parameter ALU_QUEUE_LEN = 32;
    parameter MEM_QUEUE_LEN = 32;
    parameter BRANCH_QUEUE_LEN = 16;
    parameter MULT_QUEUE_LEN = 8;
    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        preg_addr_t id;
        word_t data;
    } src_data_t;
    typedef struct packed {
        preg_addr_t dst;
        src_data_t src1, src2;
        control_t ctl;
    } entry_t;
    typedef entry_t[ALU_QUEUE_LEN-1:0] alu_queue_t;
    typedef entry_t[MEM_QUEUE_LEN-1:0] mem_queue_t;
    typedef entry_t[BRANCH_QUEUE_LEN-1:0] branch_queue_t;
    typedef entry_t[MULT_QUEUE_LEN-1:0] mult_queue_t;
    typedef logic[$clog2(ALU_QUEUE_LEN)-1:0] alu_queue_ptr_t;
    typedef logic[$clog2(MEM_QUEUE_LEN)-1:0] mem_queue_ptr_t;
    typedef logic[$clog2(BRANCH_QUEUE_LEN)-1:0] branch_queue_ptr_t;
    typedef logic[$clog2(MULT_QUEUE_LEN)-1:0] mult_queue_ptr_t;

    // write
    typedef enum logic[1:0] { ALU, MEM, BRANCH, MULT } entry_type_t;
    typedef struct packed {
        logic valid;
        entry_type_t entry_type;
        entry_t entry;
    } write_req_t;

    // read
endpackage: queue_pkg
