//  Package: renaming_pkg
//
package renaming_pkg;
    import common::*;
    import decode_pkg::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        preg_addr_t dst;
        struct packed {
            logic valid;
            preg_addr_t id;
        } src1, src2;
        creg_addr_t dst_, src1_, src2_;
        control_t ctl;
        decoded_op_t op;
        word_t imm;
        word_t pcplus8;
        exception_pkg::exception_info_t exception;
    } renaming_data_t;
    
endpackage: renaming_pkg
