//  Package: rat_pkg
//
package rat_pkg;
    import common::*;
    //  Group: Parameters
    // parameter READ_PORTS = MACHINE_WIDTH * 3;
    // parameter WRITE_PORTS = MACHINE_WIDTH;
    parameter TABLE_LEN = 70;
    parameter RELEASE_PORTS = ISSUE_WIDTH;
    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        preg_addr_t id;
    } entry_t;
    typedef entry_t [TABLE_LEN-1:0] table_t; 
endpackage: rat_pkg
