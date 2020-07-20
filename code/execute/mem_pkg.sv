//  Package: mem_pkg
//
package mem_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        vaddr_t addr;
    } read_req_t;
    typedef struct packed {
        logic valid;
        vaddr_t addr;
        word_t data;
    } write_req_t;
    
endpackage: mem_pkg
