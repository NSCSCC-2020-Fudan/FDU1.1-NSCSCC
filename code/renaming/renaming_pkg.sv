//  Package: renaming_pkg
//
package renaming_pkg;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        preg_addr_t dst, src1, src2;
        control_t ctl;
        word_t imm;
        rob_addr_t rob_addr;
    } renamed_instr_t;

    
endpackage: renaming_pkg
