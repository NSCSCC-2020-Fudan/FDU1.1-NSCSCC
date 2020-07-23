//  Package: forward_pkg
//
package forward_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic valid1, valid2;
        logic[$clog2(execute_pkg::ALU_NUM)-1:0] fw1, fw2;
    } forward_t;
    
endpackage: forward_pkg
