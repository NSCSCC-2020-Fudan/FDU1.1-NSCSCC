module commit 
    import common::*;
    import commit_pkg::*;(
    ereg_intf.commit ereg,
    commit_intf.commit self,
    forward_intf.commit forward,
    wake_intf.commit wake
);
    execute_data_t dataE;
    commit_data_t dataC;

    assign dataE = ereg.dataE;
endmodule