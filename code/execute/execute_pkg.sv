//  Package: execute_pkg
//
package execute_pkg;
    import common::*;
    import commit_pkg::*;
    //  Group: Parameters
    parameter ALU_NUM = 4;
    parameter MEM_NUM = 1;
    parameter BRU_NUM = 1;
    parameter MULT_NUM = 1;
    parameter FU_NUM = ALU_NUM + MEM_NUM + BRU_NUM + MULT_NUM;
    //  Group: Typedefs
    typedef struct packed {
        alu_commit_t[ALU_NUM-1:0] alu_commit;
        mem_commit_t[MEM_NUM-1:0] agu_commit;
        branch_commit_t[BRU_NUM-1:0] branch_commit;
        mult_commit_t[MULT_NUM-1:0] mult_commit;
    } execute_data_t;


endpackage: execute_pkg
