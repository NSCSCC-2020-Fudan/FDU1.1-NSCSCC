//  Package: rat_pkg
//
package rat_pkg;
    import common::*;
    //  Group: Parameters
    parameter READ_NUM = 12;
    parameter WRITE_NUM = 4;

    //  Group: Typedefs
    typedef struct packed {
        preg_addr_t preg_id;
        rob_pkg::rob_addr_t rob_addr;
    } entry_t;
    typedef entry_t [AREG_NUM-1:0] table_t; 
    typedef struct packed {
        logic wen;
        logic is_dst;
        areg_addr_t areg_id;
        // preg_addr_t preg_id;
    } w_req_t;
    typedef struct packed {
        areg_addr_t areg_id;
    } r_req_t;
    typedef struct packed {
        preg_addr_t preg_id;
    } r_resp_t;
endpackage: rat_pkg
