module branch_controller (
    input word_t srca, srcb,
    input branch_t branch_type,
    output logic branch_taken
);
    always_comb begin
        case (branch_type)
            T_BEQ: branch_taken = (srca == srcb);
            T_BNE: branch_taken = (srca != srcb);
            T_BGEZ: branch_taken = (~srca[31]);
            T_BLTZ: branch_taken = (srca[31]);
            T_BGTZ: branch_taken = (~srca[31] && srca != '0);
            T_BLEZ: branch_taken = (srca[31] || srca == '0);
            default: begin
                branch_taken = 1'b0;
            end
        endcase
    end
endmodule