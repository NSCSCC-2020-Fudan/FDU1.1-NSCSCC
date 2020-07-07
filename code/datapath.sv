module datapath (
    
);
    word_t pc;
    Freg_intf freg_intf(pc);

    word_t instr;
    Dreg_intf dreg_intf(instr);

    word_t pcexception;
    logic exception;
    
    Pcselect_intf(pcexception, exception);
    fetch fetch(.in(freg_intf.out), .out(dreg_intf.in), .f(pcselect_intf.fetch));
    pcselect pcselect(.in(pcselect_intf.select), .out(pcreg_intf.in));
endmodule