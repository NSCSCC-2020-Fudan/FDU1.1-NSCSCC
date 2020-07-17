//  Package: rob_pkg
//
package rob_pkg;
    import common::*;
    //  Group: Parameters
    parameter ROB_TABLE_SIZE = 4;
    

    //  Group: Typedefs
    typedef logic[ROB_TABLE_SIZE:0] rob_ptr_t;
    
    typedef struct packed {
        logic complete;
        decoded_op_t op;
        preg_addr_t preg;
        areg_addr_t areg;
        preg_addr_t opreg;
        word_t pc;
        exception::exception_t exception;
    } entry_t;
    typedef entry_t[2**ROB_TABLE_SIZE-1:0] rob_table_t;
    typedef struct packed {
        logic wen;
        word_t pc;
        
    } w_req_t;
endpackage: rob_pkg
