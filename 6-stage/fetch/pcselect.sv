`include "mips.svh"

module pcselect (
    pcselect_freg_fetch.pcselect out,
    pcselect_intf.pcselect in,
    input logic clk, resetn
);
    // logic exception_valid, is_eret;
    // always_ff @(posedge clk) begin
    //     if (~resetn) begin
    //         exception_valid <= '0;
    //         is_eret <= '0;
    //     end
    //     else if((~exception_valid) & (~is_eret)) begin
    //         exception_valid <= in.exception_valid;
    //         is_eret <= in.is_eret;
    //     end else if(~in.stallF) begin
    //         exception_valid <= in.exception_valid;
    //         is_eret <= in.is_eret;
    //     end
    // end
    assign out.pc_new = in.exception_valid      ? in.pcexception : (
                        in.is_eret              ? in.epc         : (
                        in.branch_taken         ? in.pcbranchD   : (
                        in.jr                   ? in.pcjrD       : (
                        in.jump                 ? in.pcjumpD     : 
                                                  in.pcplus4F))));
endmodule