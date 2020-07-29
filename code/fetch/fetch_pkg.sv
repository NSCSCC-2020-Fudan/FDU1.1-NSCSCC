//  Package: fetch_pkg
//
package fetch_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        word_t instr_;
        word_t pcplus4;
        word_t pcplus8;
        exception_pkg::exception_info_t exception;
    } fetch_data_t;

    
endpackage: fetch_pkg
