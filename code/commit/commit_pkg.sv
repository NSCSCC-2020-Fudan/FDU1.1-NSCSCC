//  Package: commit_pkg
//
package commit_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        exception_pkg::exception_t exception;
    } alu_commit_t;
    typedef struct packed {
        exception_pkg::exception_t exception;
    } mem_commit_t;
    typedef struct packed {
        exception_pkg::exception_t exception;
    } branch_commit_t;
    typedef struct packed {
        exception_pkg::exception_t exception;
    } mult_commit_t;
endpackage: commit_pkg
