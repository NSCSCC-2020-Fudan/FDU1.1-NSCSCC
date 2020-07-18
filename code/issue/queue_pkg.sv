//  Package: queue_pkg
//
package queue_pkg;
    import common::*;
    //  Group: Parameters
    parameter QUEUE_LEN = 32;

    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        preg_addr_t id;
        word_t data;
    } src_data_t;
    typedef struct packed {
        preg_addr_t dst;
        src_data_t src1, src2;
    } entry_t;
    typedef entry_t[QUEUE_LEN-1:0] issue_queue_t;
    
endpackage: queue_pkg
