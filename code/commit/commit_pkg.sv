//  Package: commit_pkg
//
package commit_pkg;
    import common::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        word_t data;
        rob_addr_t rob_addr;
        exception_pkg::exception_info_t exception;
    } alu_commit_t;
    typedef struct packed {
        word_t data;
        vaddr_t addr;
        rob_addr_t rob_addr;
        exception_pkg::exception_info_t exception;
    } mem_commit_t;
    typedef struct packed {
        word_t pcbranch;
        rob_addr_t rob_addr;
        exception_pkg::exception_info_t exception;
    } branch_commit_t;
    typedef struct packed {
        word_t hi, lo;
        rob_addr_t rob_addr;
        exception_pkg::exception_info_t exception;
    } mult_commit_t;
endpackage: commit_pkg
