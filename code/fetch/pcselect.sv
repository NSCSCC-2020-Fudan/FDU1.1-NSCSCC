`include "mips.svh"

module pcselect (
    pcselect_freg_fetch.pcselect out,
    pcselect_intf.pcselect in
);
    assign out.pc_new = // in.exception_valid      ? in.pcexception : (
                        in.branch_taken         ? in.pcbranchD   : (
                        in.jr                   ? in.pcjrD       : (
                        in.jump                 ? in.pcjumpD     : 
                                                  in.pcplus4F)) ;
endmodule