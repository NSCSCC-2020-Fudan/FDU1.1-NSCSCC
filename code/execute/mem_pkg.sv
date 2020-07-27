//  Package: mem_pkg
//
package mem_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        vaddr_t addr;
        logic[1:0] size;
    } read_req_t;
    typedef struct packed {
        logic valid;
        vaddr_t addr;
        word_t data;
        logic [1:0] size;
    } write_req_t;
    
endpackage: mem_pkg
