module pcselect (
    input word_t pcexception, pcbranchD, pcjrD, pcjumpD, pcplus4F,
    input logic exception, branch_taken, jr, jump,
    output word_t pcnext
);
    assign pcnext = exception            ? pcexception : (
                    branch_taken         ? pcbranchD   : (
                    jr                   ? pcjrD       : (
                    jump                 ? pcjumpD     : 
                                           pcplus4F))) ;
endmodule