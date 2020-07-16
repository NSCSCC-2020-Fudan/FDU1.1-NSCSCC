//  Package: rat_pkg
//
package rat_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        preg_addr_t preg_id;
    } entry_t;
    typedef entry_t [AREG_NUM-1:0] table_t; 
    
endpackage: rat_pkg
