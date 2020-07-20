//  Package: free_list_pkg
//
package free_list_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic busy;
    } entry_t;
    typedef entry_t[PREG_NUM-1:0] free_list_t;
//    typedef 
endpackage: free_list_pkg
