//  Package: rob_pkg
//
package rob_pkg;
    import common::*;
    //  Group: Parameters
    parameter ROB_ADDR_LEN = 4;
    

    //  Group: Typedefs
    typedef logic[ROB_ADDR_LEN:0] rob_ptr_t;
    typedef logic[ROB_ADDR_LEN-1:0] rob_addr_t;
    typedef struct packed {
        rob_addr_t id;
        logic complete_n;
        decoded_op_t op;
        preg_addr_t preg;
        areg_addr_t areg;
        preg_addr_t opreg;
        word_t pc;
        dword_t data;
        exception::exception_t exception;
    } entry_t;
    typedef entry_t[2**ROB_ADDR_LEN-1:0] rob_table_t;
    typedef struct packed {
        word_t pc;

    } w_req_t;
    typedef struct packed {
        
    } retire_resp_t;
    typedef struct packed {
        
    } commit_req_t;
endpackage: rob_pkg
