//  Package: common
//
package common;
    //  Group: Parameters
    parameter AREG_NUM = 32;
    parameter PREG_NUM = 128;
    parameter CP0_REG_NUM = 32;
    parameter CREG_NUM = AREG_NUM + CP0_REG_NUM + 2;
    // parameter ISSUE_WIDTH = 4;
    parameter ISSUE_WIDTH = 6; // maximum issue
    parameter MACHINE_WIDTH = 1; // maximum decode&renaming
    //  Group: Typedefs
    typedef logic[31:0] word_t;
    typedef logic[63:0] dword_t;
    typedef logic[31:0] vaddr_t;
    typedef logic[31:0] paddr_t;
    typedef logic[$clog2(PREG_NUM)-1:0]  preg_addr_t; // physical
    typedef logic[$clog2(AREG_NUM)-1:0]  areg_addr_t; // architectural
    typedef logic[$clog2(CREG_NUM)-1:0]  creg_addr_t; // need to be renamed
    typedef enum logic[1:0] { ALU, MEM, BRANCH, MULTI } entry_type_t;
    typedef struct packed {
        logic wen;
        areg_addr_t addr;
        word_t wd;
    } rf_w_t;
    typedef struct packed {
        logic ren;
        vaddr_t addr;
        logic[1:0] size;
    } m_r_t;
    typedef struct packed {
        logic[1:0] size;
        logic wen;
        vaddr_t addr;
        word_t wd;
    } m_w_t;
    
endpackage: common
