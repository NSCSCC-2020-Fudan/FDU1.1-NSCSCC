//  Package: free_list_pkg
//
package free_list_pkg;
    import common::*;
    //  Group: Parameters
    parameter READ_PORTS = 1;
    parameter WRITE_PORTS = 1;
    parameter RELEASE_PORTS = 1;
    //  Group: Typedefs
    typedef struct packed {
        logic busy;
    } entry_t;
    typedef entry_t[PREG_NUM-1:0] free_list_t;
    typedef struct packed {
        logic valid;
        preg_addr_t id;
    } w_req_t;
    typedef struct packed {
        preg_addr_t[READ_PORTS-1:0] id;
    } r_resp_t;
//    typedef 
endpackage: free_list_pkg
