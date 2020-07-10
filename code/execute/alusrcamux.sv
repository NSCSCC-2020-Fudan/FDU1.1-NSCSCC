module alusrcamux (
    input word_t srca, shamt,
    output word_t alusrca,
    input logic shamt_valid
);
    assign alusrca = shamt_valid ? shamt : srca;
endmodule