//  Package: execute_pkg
//
package execute_pkg;
    //  Group: Parameters
    parameter ALU_NUM = 4;
    parameter AGU_NUM = 1;
    parameter BRU_NUM = 1;
    parameter MULT_NUM = 1;
    parameter FU_NUM = ALU_NUM + AGU_NUM + BRU_NUM + MULT_NUM;
    //  Group: Typedefs
    typedef struct packed {
        
    } execute_data_t;


endpackage: execute_pkg
