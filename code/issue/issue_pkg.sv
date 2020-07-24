//  Package: issue_pkg
//
package issue_pkg;
    import common::*;
    import issue_queue_pkg::*;
    //  Group: Parameters
    

    //  Group: Typedefs
    typedef struct packed {
        word_t src1, src2, imm;
        preg_addr_t dst;
        rob_addr_t rob_addr;
        control_t ctl;
    } issued_instr_t;
    typedef struct packed {
        issued_instr_t[ALU_NUM-1:0] alu_issue;
        issued_instr_t[MEM_NUM-1:0] mem_issue;
        issued_instr_t[BRANCH_NUM-1:0] branch_issue;
        issued_instr_t[MULT_NUM-1:0] mult_issue;
    } issue_data_t;
    
endpackage: issue_pkg
