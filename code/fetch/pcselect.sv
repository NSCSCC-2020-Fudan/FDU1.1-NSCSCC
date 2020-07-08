module pcselect (
    pcselect_freg_fetch.pcselect out,
    pcselect_intf.pcselect in
);
    word_t pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F,
    logic exception, branch_taken, jr, jump,
    word_t pc_new;
    assign pc_new = exception            ? pcexception : (
                    branch_taken         ? pcbranchD   : (
                    jr                   ? pcjrD       : (
                    jump                 ? pcjumpD     : 
                                           pcplus4F))) ;
endmodule