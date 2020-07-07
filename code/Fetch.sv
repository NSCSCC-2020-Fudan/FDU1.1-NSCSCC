`include "mips.svh"

module fetch (
    Freg_intf.out in,
    Dreg_intf.in out,
    Pcselect_intf.fetch f
);
    // assign out.pcplus4 = in.pc + 32'b4;
    adder#(32) pcadder(in.pc, 32'b100, out.pcplus4);
    assign f.pcplus4F = out.pcplus4;
endmodule

module pcselect (
    // input pcsource_t srcs,
    // input pc_signal_t s,
    Pcselect_intf.select in,
    Pcreg_intf.in out
);
    assign out.pcnext = in.exception            ? in.pcexception : (
                        in.branch_taken         ? in.pcbranchD   : (
                        in.jr                   ? in.pcjrD       : (
                        in.jump                 ? in.pcjumpD     : 
                                                  in.pcplus4F))) ;
endmodule

module pcreg (
    Pcreg_intf.out in,
    Freg_intf.in out
);
    always_ff @(posedge in.clk, posedge in.reset) begin
        if (in.reset) begin
            out.pc <= '0;
        end
        else if(~in.stall) begin
            out.pc <= in.pcnext;
        end
    end
endmodule