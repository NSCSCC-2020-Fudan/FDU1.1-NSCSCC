//  Package: issue_pkg
//
package issue_pkg;
    import common::*;
    import execute_pkg::*;
    import decode_pkg::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        logic valid;
        word_t src1, src2, imm;
        preg_addr_t r1, r2, dst;
        logic forward_en1, forward_en2;
        control_t ctl;
        decoded_op_t op;
        word_t pcplus8;
        exception_pkg::exception_info_t exception;
    } issued_instr_t;
    typedef struct packed {
        issued_instr_t[ALU_NUM-1:0] alu_issue;
        issued_instr_t[MEM_NUM-1:0] mem_issue;
        issued_instr_t[BRU_NUM-1:0] branch_issue;
        issued_instr_t[MULT_NUM-1:0] mult_issue;
    } issue_data_t;
    
endpackage: issue_pkg
