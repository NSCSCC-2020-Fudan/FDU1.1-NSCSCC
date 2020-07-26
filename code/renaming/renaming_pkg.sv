//  Package: renaming_pkg
//
package renaming_pkg;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        preg_addr_t dst, src1, src2;
        creg_addr_t dst_, src1_, src2_;
        control_t ctl;
        word_t imm;
        word_t pcplus8;
        exception_pkg::exception_info_t exception;
    } renamed_instr_t;

    
endpackage: renaming_pkg
