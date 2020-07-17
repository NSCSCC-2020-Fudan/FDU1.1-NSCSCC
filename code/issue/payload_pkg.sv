//  Package: payload_pkg
//
package payload_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        control_t ctl;
        word_t data1, data2;
    } entry_t;

    
endpackage: payload_pkg
