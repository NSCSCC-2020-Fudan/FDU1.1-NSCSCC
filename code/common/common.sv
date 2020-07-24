//  Package: common
//
package common;
    //  Group: Parameters
    parameter AREG_NUM = 32;
    parameter PREG_NUM = 128;
    parameter CP0_REG_NUM = 32;
    // parameter ISSUE_NUM = 4;
    parameter ISSUE_WIDTH = 6; // maximum issue
    parameter MACHINE_WIDTH = 4; // maximum decode&renaming
    //  Group: Typedefs
    typedef logic[31:0] word_t;
    typedef logic[31:0] vaddr_t;
    typedef logic[31:0] paddr_t;
    typedef logic[$clog2(PREG_NUM)-1:0]  preg_addr_t; // physical
    typedef logic[$clog2(AREG_NUM)-1:0]  areg_addr_t; // architectural
    typedef logic[$clog2(AREG_NUM + CP0_REG_NUM + 2)-1:0] creg_addr_t;

    
endpackage: common
