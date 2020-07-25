//  Package: regfile_pkg
//
package regfile_pkg;
    import common::*;
    //  Group: Parameters
    parameter AREG_READ_PORTS = 1;
    parameter AREG_WRITE_PORTS = 1;
    parameter PREG_READ_PORTS = 1;
    parameter PREG_WRITE_PORTS = 1;
    //  Group: Typedefs
    typedef enum logic { READ_FIRST, WRITE_FIRST } mode_t;
    typedef struct packed {
        areg_addr_t id;
        mode_t mode;
    } r_req_t;
    typedef struct packed {
        logic valid;
        areg_addr_t id;
        word_t data;
    } w_req_t;
    typedef struct packed {
        word_t data;
    } r_resp_t;
endpackage: regfile_pkg
