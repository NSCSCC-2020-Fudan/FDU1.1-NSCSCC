//  Package: exc_pkg
//
package exc_pkg;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic interrupt;
        logic instr;
        logic load;
        logic save;
        logic bp;
        logic sys;
    } exception_info_t;
    
endpackage: exc_pkg
