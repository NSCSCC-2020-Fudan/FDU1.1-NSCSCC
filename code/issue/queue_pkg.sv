//  Package: queue_pkg
//
package queue_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        preg_addr_t src1, src2, dst;
        logic ready;
    } entry_t;

    
endpackage: queue_pkg
